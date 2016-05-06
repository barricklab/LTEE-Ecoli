from django.shortcuts import get_object_or_404, HttpResponse, render
from django.http import HttpResponseRedirect
from django.views import generic

from django_tables2   import RequestConfig

from LTEE_Ecoli.models import Mutation
from LTEE_Ecoli.tables  import MutationTable
from LTEE_Ecoli.forms  import SearchForm


def index(request):
    return HttpResponse("Site for searching long-term evolution experiment with E. coli mutations.")

def mutations(request):
    table = MutationTable(Mutation.objects.all())
    RequestConfig(request, paginate={"per_page": 100}).configure(table)
    return render(request, 'mutations.html', {'mutations': table})

def search(request):

    # if this is a POST request we need to process the form data
    if request.method == 'POST':
        # create a form instance and populate it with data from the request:
        form = SearchForm(request.POST)
        # check whether it's valid:
        if form.is_valid():
            # process the data in form.cleaned_data as required
            # ...
            table = MutationTable(Mutation.objects.filter(gene_name__icontains=form.cleaned_data['gene_name']))
            RequestConfig(request, paginate={"per_page": 100}).configure(table)
            return render(request, 'mutations.html', {'mutations': table})

    # if a GET (or any other method) we'll create a blank form
    else:
        form = SearchForm()

    return render(request, 'search.html', {'form': form})


def results(request):
    table = MutationTable(Mutation.objects.filter(gene="araA"))
    RequestConfig(request, paginate={"per_page": 100}).configure(table)
    return render(request, 'mutations.html', {'mutations': table})
