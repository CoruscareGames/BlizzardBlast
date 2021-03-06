# This is an auto-generated Django model module.
# You'll have to do the following manually to clean this up:
#   * Rearrange models' order
#   * Make sure each model has one field with primary_key=True
#   * Make sure each ForeignKey and OneToOneField has `on_delete` set to the desired behavior
#   * Remove `managed = False` lines if you wish to allow Django to create, modify, and delete the table
# Feel free to rename the models, but don't rename db_table values or field names.
from django.db import models


class DatabaseManagerOrdersample(models.Model):
    txn = models.BigAutoField(primary_key=True)
    date_ordered = models.DateTimeField()
    customer_name = models.CharField(max_length=255)
    total = models.IntegerField()
    milkshake_ordered = models.CharField(max_length=50)

    class Meta:
        managed = False
        db_table = 'Database_Manager_ordersample'


class AuthGroup(models.Model):
    name = models.CharField(unique=True, max_length=150)

    class Meta:
        managed = False
        db_table = 'auth_group'


class AuthGroupPermissions(models.Model):
    id = models.BigAutoField(primary_key=True)
    group = models.ForeignKey(AuthGroup, models.DO_NOTHING)
    permission = models.ForeignKey('AuthPermission', models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'auth_group_permissions'
        unique_together = (('group', 'permission'),)


class AuthPermission(models.Model):
    name = models.CharField(max_length=255)
    content_type = models.ForeignKey('DjangoContentType', models.DO_NOTHING)
    codename = models.CharField(max_length=100)

    class Meta:
        managed = False
        db_table = 'auth_permission'
        unique_together = (('content_type', 'codename'),)


class AuthUser(models.Model):
    password = models.CharField(max_length=128)
    last_login = models.DateTimeField(blank=True, null=True)
    is_superuser = models.BooleanField()
    username = models.CharField(unique=True, max_length=150)
    first_name = models.CharField(max_length=150)
    last_name = models.CharField(max_length=150)
    email = models.CharField(max_length=254)
    is_staff = models.BooleanField()
    is_active = models.BooleanField()
    date_joined = models.DateTimeField()

    class Meta:
        managed = False
        db_table = 'auth_user'


class AuthUserGroups(models.Model):
    id = models.BigAutoField(primary_key=True)
    user = models.ForeignKey(AuthUser, models.DO_NOTHING)
    group = models.ForeignKey(AuthGroup, models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'auth_user_groups'
        unique_together = (('user', 'group'),)


class AuthUserUserPermissions(models.Model):
    id = models.BigAutoField(primary_key=True)
    user = models.ForeignKey(AuthUser, models.DO_NOTHING)
    permission = models.ForeignKey(AuthPermission, models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'auth_user_user_permissions'
        unique_together = (('user', 'permission'),)


class Customization(models.Model):
    milkshake = models.OneToOneField('Milkshake', models.DO_NOTHING, primary_key=True)
    ingredient_name = models.ForeignKey('Ingredient', models.DO_NOTHING, db_column='ingredient_name')
    ingredient_quantity = models.IntegerField()
    price_delta = models.IntegerField()

    class Meta:
        managed = False
        db_table = 'customization'
        unique_together = (('milkshake', 'ingredient_name'),)


class DjangoAdminLog(models.Model):
    action_time = models.DateTimeField()
    object_id = models.TextField(blank=True, null=True)
    object_repr = models.CharField(max_length=200)
    action_flag = models.SmallIntegerField()
    change_message = models.TextField()
    content_type = models.ForeignKey('DjangoContentType', models.DO_NOTHING, blank=True, null=True)
    user = models.ForeignKey(AuthUser, models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'django_admin_log'


class DjangoContentType(models.Model):
    app_label = models.CharField(max_length=100)
    model = models.CharField(max_length=100)

    class Meta:
        managed = False
        db_table = 'django_content_type'
        unique_together = (('app_label', 'model'),)


class DjangoMigrations(models.Model):
    id = models.BigAutoField(primary_key=True)
    app = models.CharField(max_length=255)
    name = models.CharField(max_length=255)
    applied = models.DateTimeField()

    class Meta:
        managed = False
        db_table = 'django_migrations'


class DjangoSession(models.Model):
    session_key = models.CharField(primary_key=True, max_length=40)
    session_data = models.TextField()
    expire_date = models.DateTimeField()

    class Meta:
        managed = False
        db_table = 'django_session'


class Employee(models.Model):
    employee_id = models.IntegerField(primary_key=True)
    name = models.CharField(max_length=255)

    class Meta:
        managed = False
        db_table = 'employee'


class Ingredient(models.Model):
    ingredient_name = models.CharField(primary_key=True, max_length=50)
    category = models.CharField(max_length=50)
    stock = models.IntegerField()
    price_per_serving = models.IntegerField()

    class Meta:
        managed = False
        db_table = 'ingredient'


class Manager(models.Model):
    manager_date = models.DateField(primary_key=True)
    employee = models.ForeignKey(Employee, models.DO_NOTHING)
    week_date = models.ForeignKey('Week', models.DO_NOTHING, db_column='week_date')

    class Meta:
        managed = False
        db_table = 'manager'


class Milkshake(models.Model):
    milkshake_id = models.IntegerField(primary_key=True)
    recipe_name = models.ForeignKey('Recipe', models.DO_NOTHING, db_column='recipe_name')
    recipe_size = models.ForeignKey('RecipeSize', models.DO_NOTHING, db_column='recipe_size')

    class Meta:
        managed = False
        db_table = 'milkshake'


class Orders(models.Model):
    txn = models.OneToOneField('Sale', models.DO_NOTHING, db_column='txn', primary_key=True)
    milkshake = models.ForeignKey(Milkshake, models.DO_NOTHING)
    price = models.IntegerField()

    class Meta:
        managed = False
        db_table = 'orders'
        unique_together = (('txn', 'milkshake'),)


class Recipe(models.Model):
    recipe_name = models.CharField(primary_key=True, max_length=50)

    class Meta:
        managed = False
        db_table = 'recipe'


class RecipePrice(models.Model):
    recipe_name = models.OneToOneField(Recipe, models.DO_NOTHING, db_column='recipe_name', primary_key=True)
    recipe_size = models.ForeignKey('RecipeSize', models.DO_NOTHING, db_column='recipe_size')
    price = models.IntegerField()

    class Meta:
        managed = False
        db_table = 'recipe_price'
        unique_together = (('recipe_name', 'recipe_size'),)


class RecipeSize(models.Model):
    recipe_size = models.IntegerField(primary_key=True)

    class Meta:
        managed = False
        db_table = 'recipe_size'


class Sale(models.Model):
    txn = models.IntegerField(primary_key=True)
    customer_name = models.CharField(max_length=255)
    day_date = models.DateField()
    week_date = models.ForeignKey('Week', models.DO_NOTHING, db_column='week_date')

    class Meta:
        managed = False
        db_table = 'sale'


class Schedule(models.Model):
    week_date = models.OneToOneField('Week', models.DO_NOTHING, db_column='week_date', primary_key=True)
    employee = models.ForeignKey(Employee, models.DO_NOTHING)
    employee_role = models.CharField(max_length=50)

    class Meta:
        managed = False
        db_table = 'schedule'
        unique_together = (('week_date', 'employee'),)


class Servings(models.Model):
    ingredient_name = models.OneToOneField(Ingredient, models.DO_NOTHING, db_column='ingredient_name', primary_key=True)
    recipe_name = models.ForeignKey(Recipe, models.DO_NOTHING, db_column='recipe_name')
    recipe_size = models.ForeignKey(RecipeSize, models.DO_NOTHING, db_column='recipe_size')
    servings = models.IntegerField()

    class Meta:
        managed = False
        db_table = 'servings'
        unique_together = (('ingredient_name', 'recipe_name', 'recipe_size'),)


class Week(models.Model):
    week_date = models.DateField(primary_key=True)

    class Meta:
        managed = False
        db_table = 'week'
