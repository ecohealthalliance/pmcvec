OUT_DIR=products
CORPUS=pmc_oabulk_tokenized.txt
VOCAB_FILE=vocab.txt
COOCCURRENCE_FILE=cooccurrence.bin
COOCCURRENCE_SHUF_FILE=cooccurrence.shuf.bin
SAVE_FILE=vectors
VERBOSE=2
MEMORY=120
VOCAB_MIN_COUNT=5
VECTOR_SIZE=100
MAX_ITER=15
WINDOW_SIZE=15
BINARY=2
NUM_THREADS=20
X_MAX=10
OVERFLOW_LENGTH=38028356
OVERFLOW_FILE=overflow
GLOVE_DIR=GloVe
GLOVE_BIN_DIR=build
GLOVE_BD=$(GLOVE_DIR)/$(GLOVE_BIN_DIR)

all: $(OUT_DIR)/$(SAVE_FILE)

download: $(OUT_DIR)/$(CORPUS)

vocab: $(OUT_DIR)/$(VOCAB_FILE)
cooc: $(OUT_DIR)/$(COOCCURRENCE_FILE)
shuf: $(OUT_DIR)/$(COOCCURRENCE_SHUF_FILE)
embed: $(OUT_DIR)/$(SAVE_FILE)

glove_files = $(GLOVE_BD)/vocab_count $(GLOVE_BD)/cooccur $(GLOVE_BD)/shuffle $(GLOVE_BD)/glove

glove: $(glove_files)

$(OUT_DIR):
	mkdir $@

$(OUT_DIR)/$(CORPUS): $(OUT_DIR)
	./download-pmc.sh $@.tmp && mv $@.tmp $@

$(glove_files):
	curl -sL https://github.com/stanfordnlp/GloVe/archive/master.tar.gz | tar -xz && mv -f GloVe-master $(GLOVE_DIR) && make -C $(GLOVE_DIR) BUILDDIR=$(GLOVE_BIN_DIR)
	
$(OUT_DIR)/$(VOCAB_FILE): $(glove_files) $(OUT_DIR)/$(CORPUS)
	$(GLOVE_BD)/vocab_count -min-count $(VOCAB_MIN_COUNT) \
	-verbose $(VERBOSE) < $(OUT_DIR)/$(CORPUS) > $@.tmp && mv $@.tmp $@

$(OUT_DIR)/$(COOCCURRENCE_FILE): $(glove_files) $(OUT_DIR)/$(VOCAB_FILE) 
	$(GLOVE_BD)/cooccur -memory $(MEMORY) -vocab-file $(OUT_DIR)/$(VOCAB_FILE) -verbose $(VERBOSE) \
	-window-size $(WINDOW_SIZE) -overflow-length $(OVERFLOW_LENGTH) \
	-overflow-file $(OUT_DIR)/$(OVERFLOW_FILE) < $(OUT_DIR)/$(CORPUS) > $@.tmp && mv $@.tmp $@

$(OUT_DIR)/$(COOCCURRENCE_SHUF_FILE): $(glove_files) $(OUT_DIR)/$(COOCCURRENCE_FILE) $(glove_files)
	$(GLOVE_BD)/shuffle -memory $(MEMORY) -verbose $(VERBOSE) \
	< $(OUT_DIR)/$(COOCCURRENCE_FILE) > $@.tmp && mv $@.tmp $@

$(OUT_DIR)/$(SAVE_FILE): $(glove_files) $(OUT_DIR)/$(VOCAB_FILE) $(OUT_DIR)/$(COOCCURRENCE_SHUF_FILE)
	$(GLOVE_BD)/glove -save-file $@.tmp -threads $(NUM_THREADS) \
	-input-file $(OUT_DIR)/$(COOCCURRENCE_SHUF_FILE) -x-max $(X_MAX) -iter $(MAX_ITER) \
	-vector-size $(VECTOR_SIZE) -binary $(BINARY) -vocab-file $(OUT_DIR)/$(VOCAB_FILE) \
	-verbose $(VERBOSE) && mv $@.tmp $@

clean:
	rm -rf $(OUT_DIR)	$(GLOVE_DIR)
