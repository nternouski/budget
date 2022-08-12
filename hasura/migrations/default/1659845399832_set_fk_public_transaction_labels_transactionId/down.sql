alter table "public"."transaction_labels" drop constraint "transaction_labels_transactionId_fkey",
  add constraint "transaction_labels_transactionId_fkey"
  foreign key ("transactionId")
  references "public"."transactions"
  ("id") on update restrict on delete restrict;
