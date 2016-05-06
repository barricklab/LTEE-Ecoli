from __future__ import unicode_literals

from django.db import models

# Create your models here.
class Mutation(models.Model):
    start_position = models.IntegerField('Start Position', default=-1)
    end_position = models.IntegerField('End Position', default=-1)
    mutation = models.CharField('Mutation', max_length=200, default='')
    mutation_annotation = models.CharField('Mutation Annotation', max_length=2000, default='')
    gene_name = models.CharField('Gene Name', max_length=200, default='')
    gene_product = models.CharField('Gene Product', max_length=2000, default='')
    generation = models.IntegerField('Generation', default=-1)
    population = models.CharField('Population', max_length=20, default='')
    clone = models.CharField('Clone', max_length=20, default='')
