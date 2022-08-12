alter table "public"."transaction_labels" drop constraint "transaction_labels_labelId_fkey",
  add constraint "transaction_labels_labelId_fkey"
  foreign key ("labelId")
  references "public"."labels"
  ("id") on update restrict on delete cascade;
