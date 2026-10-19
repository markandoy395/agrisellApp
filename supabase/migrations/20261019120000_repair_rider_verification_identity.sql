begin;
-- Riders are linked through private.auth_identities; auth_id and
-- verification_status are no longer columns on public.riders.
create or replace function private.current_rider_verification_details()
returns jsonb language plpgsql security definer set search_path = '' as $$
declare
  target public.riders%rowtype;
  latest_action public.admin_verification_actions%rowtype;
  docs jsonb;
begin
  perform private.require_profile_editor();
  perform public.require_rate_limited_gateway();
  select * into target from public.riders
  where rider_id = private.current_rider_id();
  if not found then
    return jsonb_build_object('found', false, 'error', 'Rider record not found');
  end if;
  select * into latest_action from public.admin_verification_actions
  where entity_type = 'rider' and entity_id = target.rider_id::text
  order by created_at desc limit 1;
  select coalesce(jsonb_agg(jsonb_build_object(
    'document_id', d.document_id, 'document_type', d.document_type,
    'document_number', d.document_number,
    'verification_status', d.verification_status,
    'rejection_reason', d.rejection_reason, 'updated_at', d.updated_at
  ) order by d.created_at), '[]'::jsonb) into docs
  from public.rider_documents d where d.rider_id = target.rider_id;
  return jsonb_build_object(
    'found', true, 'rider_id', target.rider_id,
    'verification_status', case target.employment_status
      when 'active' then 'verified' when 'suspended' then 'suspended'
      else 'pending' end,
    'employment_status', target.employment_status,
    'action', latest_action.action, 'reason', latest_action.reason,
    'message', latest_action.message,
    'missing_items', to_jsonb(coalesce(latest_action.missing_items, '{}'::text[])),
    'reviewed_at', latest_action.created_at, 'documents', docs
  );
end;
$$;
-- Preserve the authenticated public wrapper and its existing execution grant.
revoke all on function private.current_rider_verification_details() from public, anon;
notify pgrst, 'reload schema';
commit;
