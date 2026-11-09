-- An admin approves a disputed word by changing status in the SQL Editor.
-- Clients cannot update harf_appeals (RLS: select-own only).
create or replace function harf_private.credit_approved_appeal()
returns trigger language plpgsql security definer set search_path=''
as $$
declare v_points integer:=10; v_player public.harf_players%rowtype;
begin
 if old.status='pending' and new.status='approved' then
   select * into v_player from public.harf_players
     where room_id=new.room_id and user_id=new.user_id for update;
   if not found then raise exception 'Oyuncu bulunamadı'; end if;
   if v_player.double_round=new.round and
      v_player.double_category=(
        select array_position(r.round_categories,new.category)
        from public.harf_rooms r where r.id=new.room_id
      ) then v_points:=20; end if;
   insert into public.harf_words(category,word) values(new.category,new.answer)
      on conflict do nothing;
   update public.harf_round_answers set accepted=true,points=v_points
      where room_id=new.room_id and round=new.round
        and user_id=new.user_id and category=new.category and accepted=false;
   if found then
     update public.harf_players set score=score+v_points
       where room_id=new.room_id and user_id=new.user_id;
   end if;
 end if;
 return new;
end $$;
drop trigger if exists harf_credit_appeal on public.harf_appeals;
create trigger harf_credit_appeal after update of status on public.harf_appeals
 for each row when(old.status is distinct from new.status)
 execute function harf_private.credit_approved_appeal();
