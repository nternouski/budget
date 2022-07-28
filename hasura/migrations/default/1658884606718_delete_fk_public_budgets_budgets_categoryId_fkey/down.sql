alter table "public"."budgets"
  add constraint "budgets_categoryId_fkey"
  foreign key ("categoryId")
  references "public"."categories"
  ("id") on update restrict on delete restrict;
