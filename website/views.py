from django.shortcuts import render
from wiki import all_text
import json
from django.http import HttpResponse
import subprocess
from subprocess import Popen, PIPE

def home(request):
    return render(request, 'index') #Index is a file in /templates


def homeInputJson(request):
    query = request.GET['query']
    result = all_text(query)
    jsonData = json.dumps(result) #This isn't valid JSON according to jQuery. Needs to use double quotes.
    print jsonData
    return HttpResponse(jsonData, content_type="application/json")


def homeInput(request):
    return render(request, 'query', {})
    

def callHaskell(request):
    PARAMETER = "[(\"iyear\", \"2009\"), (\"city\", \"kokang\")]"
    output = subprocess.check_output(['./CsvSearch', PARAMETER])
    pyDict = json.loads(output)
    print pyDictp
    return HttpResponse(output)
