-- Respect +10s personal jokers before allowing the host to advance.
create or replace function public.harf_start_round(p_room uuid)
returns void language plpgsql security definer set search_path = ''
as $$
declare v_room public.harf_rooms%rowtype; v_letter text; v_category text; v_cats text[];
begin
 select * into v_room from public.harf_rooms where id=p_room for update;
 if not found or v_room.owner_id is distinct from auth.uid() then raise exception 'Yalnızca oda sahibi'; end if;
 if v_room.status='finished' then raise exception 'Maç sona erdi'; end if;
 if (select count(*) from public.harf_players where room_id=p_room)<2 then raise exception 'En az iki oyuncu gerekli'; end if;
 if v_room.status='playing' and exists(
   select 1 from public.harf_players p
   where p.room_id=p_room and p.submitted_round<v_room.round
     and now()<v_room.started_at+
       make_interval(secs=>case when p.extra_round=v_room.round then 70 else 60 end)
 ) then raise exception 'Diğer oyuncunun süresi devam ediyor'; end if;
 if v_room.round>=v_room.match_rounds then
  update public.harf_rooms set status='finished' where id=p_room;
  return;
 end if;
 -- Every second round replaces Ülke with one surprise category.
 if mod(v_room.round+1,2)=0 then
  select s.category into v_category from (values ('Meslek'),('Yemek'),('Spor'),('Taşıt')) s(category) order by random() limit 1;
 else v_category:='Ülke'; end if;
 v_cats:=array['İsim','Şehir','Hayvan','Bitki','Eşya',v_category];
 select w.word into v_letter
 from (select distinct left(word,1) as word from public.harf_words where category='İsim') w
 where w.word<>v_room.letter and
 (select count(distinct category) from public.harf_words where category=any(v_cats) and left(word,1)=w.word)=6
 order by random() limit 1;
 if v_letter is null then raise exception 'Bu kategoriler için harf bulunamadı'; end if;
 update public.harf_rooms set letter=v_letter,round_categories=v_cats,status='playing',
 round=round+1,started_at=now()+interval '3 seconds' where id=p_room;
end; $$;

