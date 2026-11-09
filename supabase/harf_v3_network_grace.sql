-- Allow brief network delivery grace after the displayed countdown ends.
create or replace function public.harf_submit(p_room uuid,p_answers jsonb)
returns jsonb language plpgsql security definer set search_path = ''
as $$
declare r public.harf_rooms%rowtype; p public.harf_players%rowtype; v_points integer:=0;
 v_count integer:=0; v_bonus integer:=0; v_ok boolean; v_answer text; v_i integer; v_earned integer;
 v_results jsonb:='[]'::jsonb;
begin
 if jsonb_typeof(p_answers) is distinct from 'array' or jsonb_array_length(p_answers)<>6 then raise exception 'Altı cevap gerekli'; end if;
 select * into r from public.harf_rooms where id=p_room;
 if not found or r.status<>'playing' then raise exception 'Aktif tur yok'; end if;
 select * into p from public.harf_players where room_id=p_room and user_id=auth.uid() for update;
 if not found then raise exception 'Oyuncu odada değil'; end if;
 if p.submitted_round>=r.round then raise exception 'Cevaplar zaten gönderildi'; end if;
 if now()<r.started_at then raise exception 'Çark dönüyor'; end if;
 if now()>r.started_at+make_interval(secs=>case when p.extra_round=r.round then 74 else 64 end)
 then raise exception 'Süre doldu'; end if;
 for v_i in 1..6 loop
  v_answer:=upper(trim(regexp_replace(p_answers->>(v_i-1),'\s+',' ','g') collate "tr-x-icu"));
  if length(v_answer)>45 then raise exception 'Cevap çok uzun'; end if;
  select exists(select 1 from public.harf_words
   where category=r.round_categories[v_i] and word=v_answer and left(word,1)=r.letter) into v_ok;
  v_earned:=case when v_ok then 10 else 0 end;
  if v_ok then v_count:=v_count+1; end if;
  if v_ok and p.double_round=r.round and p.double_category=v_i then v_earned:=20; end if;
  v_points:=v_points+v_earned;
  insert into public.harf_round_answers(room_id,round,user_id,category,answer,accepted,points)
  values(p_room,r.round,auth.uid(),r.round_categories[v_i],v_answer,v_ok,v_earned);
  v_results:=v_results||jsonb_build_array(jsonb_build_object(
    'category',r.round_categories[v_i],'answer',v_answer,'valid',v_ok,'points',v_earned));
 end loop;
 if v_count=6 and now()<=r.started_at+interval '30 seconds' then v_bonus:=20; end if;
 v_points:=v_points+v_bonus;
 update public.harf_players set score=score+v_points,submitted_round=r.round
 where room_id=p_room and user_id=auth.uid();
 return jsonb_build_object('points',v_points,'bonus',v_bonus,'results',v_results);
end; $$;

