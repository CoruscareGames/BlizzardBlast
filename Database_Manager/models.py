from django.db import models
from django.db.models.fields import DateField
from django.utils import timezone

# Create your models here.

class Customization(models.Model):
    milkshake = models.OneToOneField('Milkshake', models.DO_NOTHING, primary_key=True)
    ingredient_name = models.ForeignKey('Ingredient', models.DO_NOTHING, db_column='ingredient_name')
    ingredient_quantity = models.IntegerField()
    price_delta = models.IntegerField()

    class Meta:
        managed = False
        db_table = 'customization'
        unique_together = (('milkshake', 'ingredient_name'),)


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

    def __str__(self):
        return self.recipe_name


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

    def __str__(self):
        if self.recipe_size == 1:
            return 'SMALL'
        if self.recipe_size == 2:
            return 'MEDIUM'
        if self.recipe_size == 3:
            return 'LARGE'

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
