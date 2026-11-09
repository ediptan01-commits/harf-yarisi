-- Harf Yarışı online MVP. Apply only to the chosen Supabase project.
-- Requires Anonymous Sign-Ins enabled in Supabase Auth.
create extension if not exists pgcrypto;
create schema if not exists harf_private;

create table if not exists public.harf_rooms (
  id uuid primary key default gen_random_uuid(),
  code text not null unique,
  owner_id uuid not null,
  status text not null default 'lobby' check (status in ('lobby','playing')),
  letter text not null default '?',
  round integer not null default 0,
  started_at timestamptz,
  created_at timestamptz not null default now()
);
create table if not exists public.harf_players (
  room_id uuid not null references public.harf_rooms(id) on delete cascade,
  user_id uuid not null,
  display_name text not null check (char_length(display_name) between 1 and 18),
  score integer not null default 0 check (score >= 0),
  submitted_round integer not null default 0,
  primary key (room_id, user_id)
);
create table if not exists public.harf_words (
  category text not null,
  word text not null,
  primary key (category, word)
);
insert into public.harf_words (category,word) values
('İsim','AHMET'),
('İsim','ALİ'),
('İsim','AYŞE'),
('İsim','ASLI'),
('İsim','BURAK'),
('İsim','BUSE'),
('İsim','CAN'),
('İsim','CEM'),
('İsim','CANSU'),
('İsim','ÇAĞLA'),
('İsim','ÇETİN'),
('İsim','ÇİĞDEM'),
('İsim','DENİZ'),
('İsim','DERYA'),
('İsim','DAVUT'),
('İsim','ELİF'),
('İsim','EMRE'),
('İsim','ECE'),
('İsim','FATMA'),
('İsim','FERHAT'),
('İsim','FIRAT'),
('İsim','GAMZE'),
('İsim','GÖKHAN'),
('İsim','GÜL'),
('İsim','HASAN'),
('İsim','HİLAL'),
('İsim','HAKAN'),
('İsim','İBRAHİM'),
('İsim','İREM'),
('İsim','İPEK'),
('İsim','KEMAL'),
('İsim','KEREM'),
('İsim','KÜBRA'),
('İsim','LEYLA'),
('İsim','LEVENT'),
('İsim','LALE'),
('İsim','MERT'),
('İsim','MURAT'),
('İsim','MELEK'),
('İsim','NAZ'),
('İsim','NİHAT'),
('İsim','NEHİR'),
('İsim','ONUR'),
('İsim','OKAN'),
('İsim','OYA'),
('İsim','PELİN'),
('İsim','PINAR'),
('İsim','POLAT'),
('İsim','RANA'),
('İsim','RECEP'),
('İsim','RIZA'),
('İsim','SELİN'),
('İsim','SEDA'),
('İsim','SERKAN'),
('İsim','TUĞBA'),
('İsim','TOLGA'),
('İsim','TUNA'),
('İsim','UMUT'),
('İsim','UFUK'),
('İsim','UĞUR'),
('İsim','YUSUF'),
('İsim','YAĞMUR'),
('İsim','YASEMİN'),
('İsim','ZEYNEP'),
('İsim','ZAFER'),
('İsim','ZEHRA'),
('Şehir','ANKARA'),
('Şehir','ADANA'),
('Şehir','ANTALYA'),
('Şehir','AYDIN'),
('Şehir','ARTVİN'),
('Şehir','AMASYA'),
('Şehir','BURSA'),
('Şehir','BOLU'),
('Şehir','BALIKESİR'),
('Şehir','BARTIN'),
('Şehir','BİLECİK'),
('Şehir','CEYHAN'),
('Şehir','CİZRE'),
('Şehir','ÇORUM'),
('Şehir','ÇANAKKALE'),
('Şehir','ÇANKIRI'),
('Şehir','DENİZLİ'),
('Şehir','DİYARBAKIR'),
('Şehir','DÜZCE'),
('Şehir','EDİRNE'),
('Şehir','ERZURUM'),
('Şehir','ESKİŞEHİR'),
('Şehir','ELAZIĞ'),
('Şehir','ERZİNCAN'),
('Şehir','FATSA'),
('Şehir','FLORANSA'),
('Şehir','FRANKFURT'),
('Şehir','GAZİANTEP'),
('Şehir','GİRESUN'),
('Şehir','GÜMÜŞHANE'),
('Şehir','HATAY'),
('Şehir','HAKKARİ'),
('Şehir','HAMBURG'),
('Şehir','İSTANBUL'),
('Şehir','İZMİR'),
('Şehir','İZMİT'),
('Şehir','KONYA'),
('Şehir','KAYSERİ'),
('Şehir','KARS'),
('Şehir','KOCAELİ'),
('Şehir','KIRŞEHİR'),
('Şehir','LONDRA'),
('Şehir','LİZBON'),
('Şehir','LÜLEBURGAZ'),
('Şehir','MANİSA'),
('Şehir','MARDİN'),
('Şehir','MUĞLA'),
('Şehir','MERSİN'),
('Şehir','NEVŞEHİR'),
('Şehir','NİĞDE'),
('Şehir','NEW YORK'),
('Şehir','ORDU'),
('Şehir','OSLO'),
('Şehir','OTTAWA'),
('Şehir','PARİS'),
('Şehir','PRAG'),
('Şehir','POLATLI'),
('Şehir','RİZE'),
('Şehir','ROMA'),
('Şehir','ROTTERDAM'),
('Şehir','SAMSUN'),
('Şehir','SİNOP'),
('Şehir','SİVAS'),
('Şehir','SAKARYA'),
('Şehir','TRABZON'),
('Şehir','TOKAT'),
('Şehir','TEKİRDAĞ'),
('Şehir','UŞAK'),
('Şehir','URFA'),
('Şehir','UTRECHT'),
('Şehir','YALOVA'),
('Şehir','YOZGAT'),
('Şehir','YÜKSEKOVA'),
('Şehir','ZONGULDAK'),
('Şehir','ZÜRİH'),
('Şehir','ZARA'),
('Hayvan','ASLAN'),
('Hayvan','AT'),
('Hayvan','AYI'),
('Hayvan','ARI'),
('Hayvan','BALIK'),
('Hayvan','BAYKUŞ'),
('Hayvan','BOĞA'),
('Hayvan','CEYLAN'),
('Hayvan','CİVCİV'),
('Hayvan','ÇAKAL'),
('Hayvan','ÇEKİRGE'),
('Hayvan','ÇİTA'),
('Hayvan','DEVE'),
('Hayvan','DOMUZ'),
('Hayvan','DELFİN'),
('Hayvan','EŞEK'),
('Hayvan','ENGEREK'),
('Hayvan','EMU'),
('Hayvan','FARE'),
('Hayvan','FİL'),
('Hayvan','FOK'),
('Hayvan','GEYİK'),
('Hayvan','GÜVERCİN'),
('Hayvan','GERGEDAN'),
('Hayvan','HOROZ'),
('Hayvan','HİNDİ'),
('Hayvan','HAMSTER'),
('Hayvan','İNEK'),
('Hayvan','İGUANA'),
('Hayvan','İPEK BÖCEĞİ'),
('Hayvan','KEDİ'),
('Hayvan','KÖPEK'),
('Hayvan','KARTAL'),
('Hayvan','KAPLAN'),
('Hayvan','KURT'),
('Hayvan','LEYLEK'),
('Hayvan','LAMA'),
('Hayvan','LEOPAR'),
('Hayvan','MAYMUN'),
('Hayvan','MARTI'),
('Hayvan','MANDA'),
('Hayvan','NARVAL'),
('Hayvan','NANDU'),
('Hayvan','ORKA'),
('Hayvan','ORANGUTAN'),
('Hayvan','PANDA'),
('Hayvan','PAPAĞAN'),
('Hayvan','PENGUEN'),
('Hayvan','RAKUN'),
('Hayvan','REN GEYİĞİ'),
('Hayvan','SERÇE'),
('Hayvan','SİNCAP'),
('Hayvan','SIRTLAN'),
('Hayvan','TAVŞAN'),
('Hayvan','TİMSAH'),
('Hayvan','TİLKİ'),
('Hayvan','UĞUR BÖCEĞİ'),
('Hayvan','USKUMRU'),
('Hayvan','YILAN'),
('Hayvan','YUNUS'),
('Hayvan','YARASA'),
('Hayvan','ZEBRA'),
('Hayvan','ZÜRAFA'),
('Bitki','ARMUT'),
('Bitki','AKASYA'),
('Bitki','AYÇİÇEĞİ'),
('Bitki','ALOE VERA'),
('Bitki','BAMBU'),
('Bitki','BEGONYA'),
('Bitki','BUĞDAY'),
('Bitki','CEVİZ'),
('Bitki','CİVANPERÇEMİ'),
('Bitki','ÇAM'),
('Bitki','ÇİLEK'),
('Bitki','ÇINAR'),
('Bitki','DEFNE'),
('Bitki','DEREOTU'),
('Bitki','DUT'),
('Bitki','ELMA'),
('Bitki','ERİK'),
('Bitki','EBEGÜMECİ'),
('Bitki','FESLEĞEN'),
('Bitki','FINDIK'),
('Bitki','FASULYE'),
('Bitki','GÜL'),
('Bitki','GELİNCİK'),
('Bitki','GÜRGEN'),
('Bitki','HAVUÇ'),
('Bitki','HURMA'),
('Bitki','HİBİSKUS'),
('Bitki','İNCİR'),
('Bitki','İĞDE'),
('Bitki','İRİS'),
('Bitki','KARANFİL'),
('Bitki','KAVAK'),
('Bitki','KİRAZ'),
('Bitki','KEKİK'),
('Bitki','LALE'),
('Bitki','LİMON'),
('Bitki','LAVANTA'),
('Bitki','MUZ'),
('Bitki','MENEKŞE'),
('Bitki','MISIR'),
('Bitki','NANE'),
('Bitki','NAR'),
('Bitki','NERGİS'),
('Bitki','ORKİDE'),
('Bitki','OKALİPTÜS'),
('Bitki','PAPATYA'),
('Bitki','PIRASA'),
('Bitki','PATATES'),
('Bitki','REYHAN'),
('Bitki','ROKA'),
('Bitki','REZENE'),
('Bitki','SÖĞÜT'),
('Bitki','SARIMSAK'),
('Bitki','SALATALIK'),
('Bitki','TURP'),
('Bitki','TARÇIN'),
('Bitki','TÜTÜN'),
('Bitki','UNUTMA BENİ'),
('Bitki','UÇKUN'),
('Bitki','YASEMİN'),
('Bitki','YONCA'),
('Bitki','YULAF'),
('Bitki','ZAMBAK'),
('Bitki','ZEYTİN'),
('Bitki','ZENCEFİL'),
('Eşya','AYNA'),
('Eşya','ANAHTAR'),
('Eşya','ARABA'),
('Eşya','BARDAK'),
('Eşya','BIÇAK'),
('Eşya','BAVUL'),
('Eşya','CEKET'),
('Eşya','CETVEL'),
('Eşya','CÜZDAN'),
('Eşya','ÇANTA'),
('Eşya','ÇATAL'),
('Eşya','ÇEKİÇ'),
('Eşya','DOLAP'),
('Eşya','DEFTER'),
('Eşya','DÜDÜK'),
('Eşya','ELDİVEN'),
('Eşya','ETEK'),
('Eşya','ELEK'),
('Eşya','FENER'),
('Eşya','FIRÇA'),
('Eşya','FİNCAN'),
('Eşya','GÖZLÜK'),
('Eşya','GİTAR'),
('Eşya','GAZETE'),
('Eşya','HALI'),
('Eşya','HAVLU'),
('Eşya','HESAP MAKİNESİ'),
('Eşya','İĞNE'),
('Eşya','İP'),
('Eşya','İBRİK'),
('Eşya','KOLTUK'),
('Eşya','KALEM'),
('Eşya','KİTAP'),
('Eşya','KAMERA'),
('Eşya','LAMBA'),
('Eşya','LAPTOP'),
('Eşya','LEĞEN'),
('Eşya','MASA'),
('Eşya','MAKAS'),
('Eşya','MİNDER'),
('Eşya','NAL'),
('Eşya','NEVRESİM'),
('Eşya','OCAK'),
('Eşya','OYUNCAK'),
('Eşya','OKLAVA'),
('Eşya','PERDE'),
('Eşya','PENCERE'),
('Eşya','PİL'),
('Eşya','RADYO'),
('Eşya','RAF'),
('Eşya','RENDE'),
('Eşya','SAAT'),
('Eşya','SANDALYE'),
('Eşya','SÜPÜRGE'),
('Eşya','TELEFON'),
('Eşya','TABAK'),
('Eşya','TARAK'),
('Eşya','UÇURTMA'),
('Eşya','UYDU'),
('Eşya','USTURA'),
('Eşya','YASTIK'),
('Eşya','YATAK'),
('Eşya','YORGAN'),
('Eşya','ZİL'),
('Eşya','ZIMBA'),
('Eşya','ZARF'),
('Ülke','ALMANYA'),
('Ülke','ARJANTİN'),
('Ülke','AVUSTRALYA'),
('Ülke','ARNAVUTLUK'),
('Ülke','BELÇİKA'),
('Ülke','BREZİLYA'),
('Ülke','BULGARİSTAN'),
('Ülke','CEZAYİR'),
('Ülke','CİBUTİ'),
('Ülke','ÇAD'),
('Ülke','ÇEKYA'),
('Ülke','ÇİN'),
('Ülke','DANİMARKA'),
('Ülke','DOMİNİKA'),
('Ülke','ESTONYA'),
('Ülke','ENDONEZYA'),
('Ülke','EKVADOR'),
('Ülke','FRANSA'),
('Ülke','FİNLANDİYA'),
('Ülke','FAS'),
('Ülke','GANA'),
('Ülke','GÜRCİSTAN'),
('Ülke','GABON'),
('Ülke','HİNDİSTAN'),
('Ülke','HOLLANDA'),
('Ülke','HIRVATİSTAN'),
('Ülke','İTALYA'),
('Ülke','İSPANYA'),
('Ülke','İRAN'),
('Ülke','IRAK'),
('Ülke','KANADA'),
('Ülke','KENYA'),
('Ülke','KAZAKİSTAN'),
('Ülke','LETONYA'),
('Ülke','LİTVANYA'),
('Ülke','LÜBNAN'),
('Ülke','MISIR'),
('Ülke','MEKSİKA'),
('Ülke','MACARİSTAN'),
('Ülke','NORVEÇ'),
('Ülke','NİJERYA'),
('Ülke','NEPAL'),
('Ülke','UMMAN'),
('Ülke','ORTA AFRİKA CUMHURİYETİ'),
('Ülke','POLONYA'),
('Ülke','PORTEKİZ'),
('Ülke','PAKİSTAN'),
('Ülke','ROMANYA'),
('Ülke','RUSYA'),
('Ülke','RUANDA'),
('Ülke','SIRBİSTAN'),
('Ülke','SİNGAPUR'),
('Ülke','SUDAN'),
('Ülke','TÜRKİYE'),
('Ülke','TUNUS'),
('Ülke','TAYLAND'),
('Ülke','UGANDA'),
('Ülke','UKRAYNA'),
('Ülke','URUGUAY'),
('Ülke','YUNANİSTAN'),
('Ülke','YENİ ZELANDA'),
('Ülke','YEMEN'),
('Ülke','ZAMBİYA'),
('Ülke','ZİMBABVE')
on conflict (category,word) do nothing;

create or replace function harf_private.is_member(p_room uuid)
returns boolean language sql stable security definer set search_path = ''
as $$
  select exists (
    select 1 from public.harf_players
    where room_id = p_room and user_id = (select auth.uid())
  );
$$;

alter table public.harf_rooms enable row level security;
alter table public.harf_players enable row level security;
alter table public.harf_words enable row level security;

drop policy if exists harf_room_read on public.harf_rooms;
create policy harf_room_read on public.harf_rooms for select to authenticated
using (harf_private.is_member(id));
drop policy if exists harf_player_read on public.harf_players;
create policy harf_player_read on public.harf_players for select to authenticated
using (harf_private.is_member(room_id));

revoke all on public.harf_rooms, public.harf_players, public.harf_words from anon, authenticated;
grant select on public.harf_rooms, public.harf_players to authenticated;
revoke all on schema harf_private from public;
grant usage on schema harf_private to authenticated;
grant execute on function harf_private.is_member(uuid) to authenticated;

create or replace function public.harf_create_room(p_name text)
returns jsonb language plpgsql security definer set search_path = ''
as $$
declare v_id uuid; v_code text; v_uid uuid := auth.uid(); v_i integer;
begin
  if v_uid is null then raise exception 'Oturum açılmadı'; end if;
  if char_length(trim(p_name)) not between 1 and 18 then raise exception 'Oyuncu adı 1-18 karakter olmalı'; end if;
  for v_i in 1..10 loop
    v_code := upper(substr(md5(random()::text || clock_timestamp()::text),1,6));
    begin
      insert into public.harf_rooms(code, owner_id) values (v_code,v_uid) returning id into v_id;
      exit;
    exception when unique_violation then continue;
    end;
  end loop;
  if v_id is null then raise exception 'Oda oluşturulamadı'; end if;
  insert into public.harf_players(room_id,user_id,display_name) values (v_id,v_uid,trim(p_name));
  return jsonb_build_object('id',v_id,'code',v_code);
end;
$$;

create or replace function public.harf_join_room(p_code text, p_name text)
returns jsonb language plpgsql security definer set search_path = ''
as $$
declare v_room public.harf_rooms%rowtype; v_uid uuid := auth.uid();
begin
  if v_uid is null then raise exception 'Oturum açılmadı'; end if;
  if char_length(trim(p_name)) not between 1 and 18 then raise exception 'Oyuncu adı 1-18 karakter olmalı'; end if;
  select * into v_room from public.harf_rooms where code = upper(trim(p_code)) for update;
  if not found then raise exception 'Oda bulunamadı'; end if;
  if v_room.status <> 'lobby' then raise exception 'Oyun başladı'; end if;
  if not exists (select 1 from public.harf_players where room_id=v_room.id and user_id=v_uid)
      and (select count(*) from public.harf_players where room_id=v_room.id) >= 4 then
    raise exception 'Oda dolu';
  end if;
  insert into public.harf_players(room_id,user_id,display_name)
    values (v_room.id,v_uid,trim(p_name))
    on conflict (room_id,user_id) do update set display_name=excluded.display_name;
  return jsonb_build_object('id',v_room.id,'code',v_room.code);
end;
$$;

create or replace function public.harf_start_round(p_room uuid)
returns void language plpgsql security definer set search_path = ''
as $$
declare v_room public.harf_rooms%rowtype; v_letter text;
begin
  select * into v_room from public.harf_rooms where id=p_room for update;
  if not found or v_room.owner_id is distinct from auth.uid() then raise exception 'Yalnızca oda sahibi başlatabilir'; end if;
  if (select count(*) from public.harf_players where room_id=p_room) < 2 then
    raise exception 'Oyun için en az 2 oyuncu gerekli';
  end if;
  if v_room.status='playing' and now() < v_room.started_at + interval '60 seconds' then
    raise exception 'Tur henüz bitmedi';
  end if;
  select left(word,1) into v_letter from public.harf_words
    group by left(word,1) having count(distinct category)=6 and left(word,1)<>v_room.letter
    order by random() limit 1;
  if v_letter is null then raise exception 'Harf bulunamadı'; end if;
  update public.harf_rooms set letter=v_letter,status='playing',round=round+1,started_at=now()
    where id=p_room;
end;
$$;

create or replace function public.harf_submit(p_room uuid, p_answers jsonb)
returns integer language plpgsql security definer set search_path = ''
as $$
declare
  v_room public.harf_rooms%rowtype;
  v_player public.harf_players%rowtype;
  v_points integer;
begin
  if jsonb_typeof(p_answers) is distinct from 'array' or jsonb_array_length(p_answers)<>6
    then raise exception 'Altı cevap gerekli'; end if;
  if exists (select 1 from jsonb_array_elements_text(p_answers) as x(value) where char_length(x.value)>45)
    then raise exception 'Cevap çok uzun'; end if;
  select * into v_room from public.harf_rooms where id=p_room;
  if not found or v_room.status<>'playing' then raise exception 'Aktif tur yok'; end if;
  if now() > v_room.started_at + interval '70 seconds' then raise exception 'Süre doldu'; end if;
  select * into v_player from public.harf_players
    where room_id=p_room and user_id=auth.uid() for update;
  if not found then raise exception 'Bu odada oyuncu değilsiniz'; end if;
  if v_player.submitted_round >= v_room.round then raise exception 'Tur zaten gönderildi'; end if;

  select (count(*)*10)::integer into v_points
    from jsonb_array_elements_text(p_answers) with ordinality as a(answer,idx)
    join public.harf_words w
      on w.category=(array['İsim','Şehir','Hayvan','Bitki','Eşya','Ülke'])[a.idx]
      and w.word=a.answer
      and left(w.word,1)=v_room.letter;

  update public.harf_players set score=score+v_points, submitted_round=v_room.round
    where room_id=p_room and user_id=auth.uid();
  return v_points;
end;
$$;

revoke execute on function public.harf_create_room(text) from public, anon;
revoke execute on function public.harf_join_room(text,text) from public, anon;
revoke execute on function public.harf_start_round(uuid) from public, anon;
revoke execute on function public.harf_submit(uuid,jsonb) from public, anon;
grant execute on function public.harf_create_room(text), public.harf_join_room(text,text),
  public.harf_start_round(uuid), public.harf_submit(uuid,jsonb) to authenticated;
