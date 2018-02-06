# Word Embeddings for Biomedical Literature

This repo produces word embeddings for the biomedical scientific literature by
running the [GloVe](https://nlp.stanford.edu/projects/glove/) algorithm on the
[PubMed Open Access Subset](https://www.ncbi.nlm.nih.gov/pmc/tools/openftlist/) corpus.

The workflow is in the `Makefile`.  Running `make` will

-   Download the PMC OA corpus, processing it as a stream into a single tokenized
    text file.
-   Download the GloVe program from it's [GitHub repository](https://github.com/stanfordnlp/GloVe) and compile its binaries
-   Build a vocabulary, a co-occurrance matrix, a shuffled co-occurrence matrix,
    and finally embeddings, putting them into a `products/` directory by default.
    
Most parameters are set in the Makefile.  You can find documentation of the
parameters in the [source file of GloVe](https://github.com/stanfordnlp/GloVe/tree/master/src).
    
A Dockerfile is provided to run  this in a small reproducible environment.  Run
the dockerfile with the command

    docker build . -t pmcv && docker run -v $(pwd):/pmcvec pmcv