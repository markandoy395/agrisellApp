# Delivery normalization rollback

The migration deliberately retains all legacy delivery columns. To roll the
application back, point Flutter at the legacy flattened columns first, then:

1. Drop the four delivery/storage RPCs created by the migration.
2. Drop the delivery status triggers and their private trigger functions.
3. Drop the storage object policies and the private `delivery-proofs` bucket
   only after its objects have been copied or confirmed disposable.
4. Drop the five child tables in dependency-safe order.
5. Remove the additive `deliveries` columns only after restoring assignments
   from `private.rider_delivery_assignments`.

Do not drop the child tables before verifying that legacy location, proof, and
payment columns still contain every value needed by the prior application.
