from django import forms

class SearchForm(forms.Form):
    gene_name = forms.CharField(label='Gene name', max_length=100)
