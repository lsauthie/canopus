import spacy
import pathlib

#special loading method because we want to deploy the webapp on Azure
current_path = pathlib.Path(__file__).parent
nlp = spacy.load(current_path / 'en_core_web_md-3.2.0')

'''
Compute similarities among a list of strings.
For each value, identify all similar values in the list. This is done with an standard integrated loop. We try to match similarities between 
a source and a target in the same list - once a similarity is found, the target is pruned (with '-1').

A target can only be similar to one source (this is controlled with the INT value in the tuple (i,0)) - '-1' is a match, '>0' hast x matches.

Return = {string1:[(string2,simvalue1),(string3,simvalue3)], string5:[]}
'''
def sim(l_str, similarity_ratio=0.9):

    l_init = [(i, 0) for i in l_str]
    d_out = {}
    
    for i in range(0,len(l_init)):
        
        rx,ry = l_init[i] #get tuple from the list, x - string, y - number of occurances
        s1 = nlp(rx)
        if ry < 0: #a similarity has already been found and set to '-1'
            continue    
    
        l_out = []
    
        for j in range(i+1,len(l_init)): #integrated loop
            
            px, py = l_init[j]
            if py >= 0: #can only be similar to one value - is set to '-1' if a similarity is found
                
                sim_compute = s1.similarity(nlp(px))
                                                
                if  sim_compute > similarity_ratio: #check similarity using NLP magic
                    ry += 1 #increase number of similarity for the source
                    l_init[i] = (rx, ry)           
                    l_init[j] = (px, -1) #can only be similar to one source
                    
                    l_out.append((px, sim_compute))
                    
        d_out[rx] = l_out
    
    return d_out


    



