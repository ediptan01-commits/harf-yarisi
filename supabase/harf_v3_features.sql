-- Harf Yarışı V3: server-authoritative multiplayer match, jokers, bonus and appeals.
-- All private mutations are guarded by auth.uid(); all tables use RLS.
alter table public.harf_rooms add column if not exists mode text not null default 'friends';
alter table public.harf_rooms add column if not exists match_rounds integer not null default 3;
alter table public.harf_rooms add column if not exists round_categories text[] not null default array['İsim','Şehir','Hayvan','Bitki','Eşya','Ülke'];
alter table public.harf_rooms drop constraint if exists harf_rooms_status_check;
alter table public.harf_rooms add constraint harf_rooms_status_check check (status in ('lobby','playing','finished'));
alter table public.harf_rooms add constraint harf_rooms_match_rounds_check check (match_rounds in (3,5));
alter table public.harf_rooms add constraint harf_rooms_mode_check check (mode in ('duel','friends'));
alter table public.harf_players add column if not exists used_hint boolean not null default false;
alter table public.harf_players add column if not exists used_double boolean not null default false;
alter table public.harf_players add column if not exists used_extra boolean not null default false;
alter table public.harf_players add column if not exists extra_round integer not null default 0;
alter table public.harf_players add column if not exists double_round integer not null default 0;
alter table public.harf_players add column if not exists double_category integer not null default 0;
alter table public.harf_players add column if not exists hint_round integer not null default 0;

create table if not exists public.harf_round_answers (
 room_id uuid not null references public.harf_rooms(id) on delete cascade,
 round integer not null,
 user_id uuid not null,
 category text not null,
 answer text not null,
 accepted boolean not null,
 points integer not null default 0,
 primary key(room_id,round,user_id,category)
);
create table if not exists public.harf_appeals (
 id uuid primary key default gen_random_uuid(),
 room_id uuid not null references public.harf_rooms(id) on delete cascade,
 round integer not null,
 user_id uuid not null,
 category text not null,
 answer text not null,
 status text not null default 'pending' check(status in ('pending','approved','rejected')),
 created_at timestamptz not null default now(),
 unique(room_id,round,user_id,category)
);
alter table public.harf_round_answers enable row level security;
alter table public.harf_appeals enable row level security;
revoke all on public.harf_round_answers, public.harf_appeals from anon,authenticated;
grant select on public.harf_round_answers, public.harf_appeals to authenticated;
drop policy if exists harf_own_answers on public.harf_round_answers;
create policy harf_own_answers on public.harf_round_answers for select to authenticated
using(user_id=(select auth.uid()));
drop policy if exists harf_own_appeals on public.harf_appeals;
create policy harf_own_appeals on public.harf_appeals for select to authenticated
using(user_id=(select auth.uid()));

insert into public.harf_words(category,word) values
('Meslek','AVUKAT'),('Meslek','AŞÇI'),('Meslek','BAHÇIVAN'),('Meslek','BERBER'),('Meslek','BİYOLOG'),('Meslek','ÇİFTÇİ'),('Meslek','DOKTOR'),('Meslek','DİŞ HEKİMİ'),('Meslek','EBE'),('Meslek','ECZACI'),('Meslek','ELEKTRİKÇİ'),('Meslek','FIRINCI'),('Meslek','FOTOĞRAFÇI'),('Meslek','GAZETECİ'),('Meslek','GEMİCİ'),('Meslek','GARSON'),('Meslek','HAKİM'),('Meslek','HEMŞİRE'),('Meslek','İTFAİYECİ'),('Meslek','İNŞAAT MÜHENDİSİ'),('Meslek','KASAP'),('Meslek','KUAFÖR'),('Meslek','KAPTAN'),('Meslek','MİMAR'),('Meslek','MÜHENDİS'),('Meslek','MARANGOZ'),('Meslek','MÜZİSYEN'),('Meslek','ÖĞRETMEN'),('Meslek','OYUNCU'),('Meslek','POLİS'),('Meslek','PİLOT'),('Meslek','RESSAM'),('Meslek','ŞOFÖR'),('Meslek','SAVCI'),('Meslek','TERZİ'),('Meslek','TEKNİSYEN'),('Meslek','USTA'),('Meslek','VETERİNER'),('Meslek','YAZAR'),('Meslek','YAZILIMCI'),
('Yemek','ADANA KEBAP'),('Yemek','AŞURE'),('Yemek','BAKLAVA'),('Yemek','BÖREK'),('Yemek','BAMYA'),('Yemek','CİĞER'),('Yemek','ÇORBA'),('Yemek','ÇİĞ KÖFTE'),('Yemek','DOLMA'),('Yemek','DÖNER'),('Yemek','EZOGELİN ÇORBASI'),('Yemek','ERİŞTE'),('Yemek','FASULYE'),('Yemek','GÖZLEME'),('Yemek','GÜLLAÇ'),('Yemek','HAMBURGER'),('Yemek','HELVA'),('Yemek','İMAM BAYILDI'),('Yemek','İÇLİ KÖFTE'),('Yemek','KARNIYARIK'),('Yemek','KÖFTE'),('Yemek','KEŞKEK'),('Yemek','LAHMACUN'),('Yemek','LAZ BÖREĞİ'),('Yemek','MANTI'),('Yemek','MENEMEN'),('Yemek','MAKARNA'),('Yemek','NOHUT'),('Yemek','OMLET'),('Yemek','PİLAV'),('Yemek','PİDE'),('Yemek','REVANİ'),('Yemek','SARMA'),('Yemek','SÜTLAÇ'),('Yemek','ŞAKŞUKA'),('Yemek','TARHANA'),('Yemek','TÜRLÜ'),('Yemek','UN HELVASI'),('Yemek','YAĞLAMA'),('Yemek','ZEYTİNYAĞLI ENGİNAR'),
('Spor','ATLETİZM'),('Spor','ATCILIK'),('Spor','BADMİNTON'),('Spor','BASKETBOL'),('Spor','BOKS'),('Spor','BİSİKLET'),('Spor','CİMNASTİK'),('Spor','CURLING'),('Spor','ÇİM HOKEYİ'),('Spor','DAĞCILIK'),('Spor','DALGIÇLIK'),('Spor','ESKRİM'),('Spor','FUTBOL'),('Spor','GOLF'),('Spor','GÜREŞ'),('Spor','HALTER'),('Spor','HENTBOL'),('Spor','JUDO'),('Spor','KARATE'),('Spor','KAYAK'),('Spor','KÜREK'),('Spor','MASA TENİSİ'),('Spor','OKÇULUK'),('Spor','PİLATES'),('Spor','RAGBİ'),('Spor','SATRANÇ'),('Spor','SURF'),('Spor','SU TOPU'),('Spor','ŞİŞME BOT YARIŞI'),('Spor','TENİS'),('Spor','TRİATLON'),('Spor','VOLEYBOL'),('Spor','YÜZME'),('Spor','YELKEN'),
('Taşıt','ARABA'),('Taşıt','AMBULANS'),('Taşıt','BİSİKLET'),('Taşıt','BULDOZER'),('Taşıt','BUHARLI TREN'),('Taşıt','CİP'),('Taşıt','ÇEKİCİ'),('Taşıt','DENİZALTI'),('Taşıt','DOLMUŞ'),('Taşıt','ELEKTRİKLİ OTOMOBİL'),('Taşıt','FERİBOT'),('Taşıt','FAYTON'),('Taşıt','GEMİ'),('Taşıt','GONDOL'),('Taşıt','HELİKOPTER'),('Taşıt','İTFAİYE ARACI'),('Taşıt','KAMYON'),('Taşıt','KAMYONET'),('Taşıt','KAYIK'),('Taşıt','LOKOMOTİF'),('Taşıt','MİNİBÜS'),('Taşıt','MOTOSİKLET'),('Taşıt','METRO'),('Taşıt','OTOBÜS'),('Taşıt','OTOMOBİL'),('Taşıt','PLANÖR'),('Taşıt','RÖMORK'),('Taşıt','SERVİS ARACI'),('Taşıt','SANDAL'),('Taşıt','ŞİLEP'),('Taşıt','TAKSİ'),('Taşıt','TIR'),('Taşıt','TREN'),('Taşıt','TRAMVAY'),('Taşıt','UÇAK'),('Taşıt','VAPUR'),('Taşıt','YAT'),('Taşıt','YELKENLİ'),('Taşıt','ZEPLİN')
on conflict do nothing;

-- Signature change to support room mode and 3/5 round matches.
drop function if exists public.harf_create_room(text);
create function public.harf_create_room(p_name text, p_mode text default 'friends', p_match_rounds integer default 3)
returns jsonb language plpgsql security definer set search_path = ''
as $$
declare v_id uuid; v_code text; v_uid uuid:=auth.uid(); v_i integer;
begin
 if v_uid is null then raise exception 'Oturum açılmadı'; end if;
 if length(trim(p_name)) not between 1 and 18 then raise exception 'Oyuncu adı 1-18 karakter olmalı'; end if;
 if p_mode not in ('friends','duel') or p_match_rounds not in (3,5) then raise exception 'Geçersiz maç ayarı'; end if;
 for v_i in 1..10 loop
  v_code:=upper(substr(md5(random()::text||clock_timestamp()::text),1,6));
  begin
   insert into public.harf_rooms(code,owner_id,mode,match_rounds) values(v_code,v_uid,p_mode,p_match_rounds) returning id into v_id;
   exit;
  exception when unique_violation then continue;
  end;
 end loop;
 if v_id is null then raise exception 'Oda oluşturulamadı'; end if;
 insert into public.harf_players(room_id,user_id,display_name) values(v_id,v_uid,trim(p_name));
 return jsonb_build_object('id',v_id,'code',v_code);
end; $$;

create or replace function public.harf_join_room(p_code text,p_name text)
returns jsonb language plpgsql security definer set search_path = ''
as $$
declare v_room public.harf_rooms%rowtype; v_uid uuid:=auth.uid(); v_limit integer;
begin
 if v_uid is null then raise exception 'Oturum açılmadı'; end if;
 if length(trim(p_name)) not between 1 and 18 then raise exception 'Oyuncu adı 1-18 karakter olmalı'; end if;
 select * into v_room from public.harf_rooms where code=upper(trim(p_code)) for update;
 if not found then raise exception 'Oda bulunamadı'; end if;
 if v_room.status<>'lobby' then raise exception 'Maç başladı'; end if;
 v_limit:=case when v_room.mode='duel' then 2 else 4 end;
 if not exists(select 1 from public.harf_players where room_id=v_room.id and user_id=v_uid)
 and (select count(*) from public.harf_players where room_id=v_room.id)>=v_limit then raise exception 'Oda dolu'; end if;
 insert into public.harf_players(room_id,user_id,display_name) values(v_room.id,v_uid,trim(p_name))
 on conflict(room_id,user_id) do update set display_name=excluded.display_name;
 return jsonb_build_object('id',v_room.id,'code',v_room.code);
end; $$;

create or replace function public.harf_start_round(p_room uuid)
returns void language plpgsql security definer set search_path = ''
as $$
declare v_room public.harf_rooms%rowtype; v_letter text; v_category text; v_cats text[];
begin
 select * into v_room from public.harf_rooms where id=p_room for update;
 if not found or v_room.owner_id is distinct from auth.uid() then raise exception 'Yalnızca oda sahibi'; end if;
 if v_room.status='finished' then raise exception 'Maç sona erdi'; end if;
 if (select count(*) from public.harf_players where room_id=p_room)<2 then raise exception 'En az iki oyuncu gerekli'; end if;
 if v_room.status='playing' and now()<v_room.started_at+interval '60 seconds'
  and exists(select 1 from public.harf_players where room_id=p_room and submitted_round<v_room.round)
 then raise exception 'Tur devam ediyor'; end if;
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

create or replace function public.harf_use_joker(p_room uuid,p_kind text,p_category integer default 0)
returns jsonb language plpgsql security definer set search_path = ''
as $$
declare r public.harf_rooms%rowtype; p public.harf_players%rowtype; v_word text;
begin
 select * into r from public.harf_rooms where id=p_room;
 if not found or r.status<>'playing' then raise exception 'Aktif tur yok'; end if;
 select * into p from public.harf_players where room_id=p_room and user_id=auth.uid() for update;
 if not found then raise exception 'Odada değilsin'; end if;
 if p.submitted_round>=r.round then raise exception 'Cevaplar gönderildi'; end if;
 if now()<r.started_at or now()>r.started_at+interval '60 seconds'
 then raise exception 'Joker süresi bitti'; end if;
 if p_kind='extra' then
  if p.used_extra then raise exception 'Süre jokeri kullanıldı'; end if;
  update public.harf_players set used_extra=true,extra_round=r.round where room_id=p_room and user_id=auth.uid();
  return jsonb_build_object('kind','extra','seconds',10);
 elsif p_kind='double' then
  if p.used_double then raise exception 'Çift puan jokeri kullanıldı'; end if;
  if p_category not between 1 and 6 then raise exception 'Kategori seç'; end if;
  update public.harf_players set used_double=true,double_round=r.round,double_category=p_category
   where room_id=p_room and user_id=auth.uid();
  return jsonb_build_object('kind','double','category',r.round_categories[p_category]);
 elsif p_kind='hint' then
  if p.used_hint then raise exception 'İpucu kullanıldı'; end if;
  if p_category not between 1 and 6 then raise exception 'Kategori seç'; end if;
  select word into v_word from public.harf_words where category=r.round_categories[p_category]
   and left(word,1)=r.letter order by random() limit 1;
  if v_word is null then raise exception 'İpucu yok'; end if;
  update public.harf_players set used_hint=true,hint_round=r.round where room_id=p_room and user_id=auth.uid();
  return jsonb_build_object('kind','hint','category',r.round_categories[p_category],
    'clue',left(v_word,least(2,length(v_word)))||'… ('||length(v_word)||' harf)');
 else raise exception 'Bilinmeyen joker'; end if;
end; $$;

drop function if exists public.harf_submit(uuid,jsonb);
create function public.harf_submit(p_room uuid,p_answers jsonb)
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
 if now()>r.started_at+make_interval(secs=>case when p.extra_round=r.round then 70 else 60 end)
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

create or replace function public.harf_appeal(p_room uuid,p_round integer,p_category text)
returns jsonb language plpgsql security definer set search_path = ''
as $$
declare a public.harf_round_answers%rowtype; v_id uuid;
begin
 select * into a from public.harf_round_answers
 where room_id=p_room and round=p_round and user_id=auth.uid() and category=p_category;
 if not found or a.accepted or length(a.answer)<2 then raise exception 'İtiraz edilebilecek reddedilmiş cevap yok'; end if;
 insert into public.harf_appeals(room_id,round,user_id,category,answer)
 values(p_room,p_round,auth.uid(),p_category,a.answer)
 on conflict(room_id,round,user_id,category) do update set status=public.harf_appeals.status
 returning id into v_id;
 return jsonb_build_object('id',v_id,'status','pending');
end; $$;

revoke execute on function public.harf_create_room(text,text,integer),
 public.harf_join_room(text,text),public.harf_start_round(uuid),
 public.harf_use_joker(uuid,text,integer),public.harf_submit(uuid,jsonb),
 public.harf_appeal(uuid,integer,text) from public,anon;
grant execute on function public.harf_create_room(text,text,integer),
 public.harf_join_room(text,text),public.harf_start_round(uuid),
 public.harf_use_joker(uuid,text,integer),public.harf_submit(uuid,jsonb),
 public.harf_appeal(uuid,integer,text) to authenticated;
