
About PolyMarker
================


PolyMarker is an automated bioinformatics pipeline for SNP assay development which increases the probability of generating homoeologue-specific assays for polyploid wheat. PolyMarker generates a multiple alignment between the target SNP sequence and the IWGSC chromosome survey sequences ([IWGSC, 2014](http://dx.doi.org/10.1126/science.1251788) ) for each of the three wheat genomes. It then generates a mask with informative positions which are highlighted with respect to the target genome.

These positions include (see figure for example):

* **Varietal polymorphism:** this is the SNP that is targeted in the assay (&)
* **Genome specific:** this is a homoeologous polymorphism which is *only* present in the target genome (upper case)
* **Genome semi-specific:** this is a homoeologous polymorphism which is found in 2 of the 3 genomes, hence it discriminates against one of the off-target genomes (lowercase)
* **Homoeologous:** if the target varietal SNP is also a homoeologous polymorphism between A,B and D genomes in the reference Chinese Spring

PolyMarker will generate KASP assays (read more) which are based on a three primer system. Two diagnostic primers incorporate the alternative varietal SNP at the 3' end, but are otherwise similar (black boxed primers in figure). The third common primer is preferentially selected to incorporate a genome-specific base at the 3' end (red boxed primer in figure), or a semi-specific base in the absence of an adequate genome specific position.

The code of the PolyMarker pipeline is available in [github](https://github.com/TGAC/bioruby-polyploid-tools).








Using PolyMarker
----------------

* The input file must be uploaded as a CSV file (can be exported from Excel) with the following columns: 
	* **Gene id**: An unique identifier for the assay. It must be unique on each run
	* **Target chromosome**: In the form 1A, 2D, 7B, etc...
	* **Sequence**: The sequence flanking the SNP. The SNP must be marked in the format **[A/T]** for a varietal SNP with alternative bases, A or T.
* PolyMarker takes ~1 minute per marker assuming an input sequence of 200 bp (with the varietal SNP in the middle). [Longer sequences can be used, but this will slow down the initial BLAST against the wheat survey sequence. We have not seen improvement in performance with longer sequences; therefore we recommend 200-bp of input sequence. The final multiple alignment for the primer design only considers 100-bp on either side of the target varietal SNP.]
* Exonerate is used to search for the contigs which align to the SNP. By default, the miniumm identity used to match across the genomes it is 90% and the model used is est2genome.
	  		 
Example
-------


### Input file ###
The example input file contains three markers to design. 

```
Gene_1,6B,GATAAGCGATGACGATACGGACGACA[A/T]ACGGGGGACGAGGGATACGAT 
Gene_2,2A,CGATAGCATAGCATGGCGTTAGCAGT[G/C]TAGTACGATAGATCAGTACGA 
Ta#S58861868,1A,CATACTGATGACACGATTGGCTACSGGCCTTGAAGATAGMAGCAGAT[A/G]ACTTCAGTGTAATCCAAGTTGACTG
```

### Output: mask ###

The mask contains the details of the local alignment 

<img src='<%= image_path("mask.png") %>' alt="Drawing" style="width: 800px;"/>
