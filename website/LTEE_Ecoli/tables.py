import django_tables2 as tables
from django.utils.safestring import mark_safe
from LTEE_Ecoli.models import Mutation


class HTMLColumn(tables.Column):
    def render(self, value):
        return mark_safe(value)

class MutationTable(tables.Table):
    class Meta:
        model = Mutation
        attrs = {"class": "paleblue"}
        exclude = {"id", "end_position"}
        sequence = ("population", "generation", "clone", "start_position", "mutation", "mutation_annotation", "gene_name", "gene_product" )
    population = tables.Column(verbose_name= 'Pop')
    generation = tables.Column(verbose_name= 'Gen')
    clone = tables.Column(verbose_name= '')
    start_position = tables.Column(verbose_name= 'Position')
    end_position = tables.Column()
    mutation = HTMLColumn()
    mutation_annotation = HTMLColumn(verbose_name= 'Annotation')
    gene_name = HTMLColumn(verbose_name= 'Gene')
    gene_product = HTMLColumn(verbose_name= 'Description')
