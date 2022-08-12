alter table "public"."budget_categories" drop constraint "budget_categories_categoryId_fkey",
  add constraint "budget_categories_categoryId_fkey"
  foreign key ("categoryId")
  references "public"."categories"
  ("id") on update restrict on delete restrict;
