import mmap
import time

def mmapUsage():
    start=time.time()
    with open("", "r+b") as f:
        # memory-mapInput the file, size 0 means whole file
        mapInput = mmap.mmap(f.fileno(), 0)
        # read content via standard file methods
        L=list()
        for s in iter(mapInput.readline, ""):
            L.append(s)
        print ("List length: " ,len(L))
        #print "Sample element: ",L[1]
        mapInput.close()
        end=time.time()
        print ("Time for completion",end-start)

print (mmapUsage())
