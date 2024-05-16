INCFLAGS = -I/usr/local/include/ -I./src/

CPP = g++
CPPFLAGS = -std=c++11 -g -O3 $(INCFLAGS) -fopenmp -ffast-math -Wall -Wno-strict-aliasing -lpthread
CPPFLAGSPG = -std=c++11 -g -O3 $(INCFLAGS) -fopenmp -Wall -Wno-strict-aliasing -lpthread -pg
LINKERFLAGS = -lz
LINKERFLAGSPG = -lz -pg
DEBUGFLAGS = -g -ggdb $(INCFLAGS)
HEADERS=$(shell find . -name '*.hpp')


all: apps tests 
apps: example_apps/connectedcomponents example_apps/pagerank example_apps/pagerank_functional example_apps/communitydetection example_apps/unionfind_connectedcomps example_apps/stronglyconnectedcomponents example_apps/trianglecounting example_apps/randomwalks example_apps/minimumspanningforest
als: example_apps/matrix_factorization/als_edgefactors  example_apps/matrix_factorization/als_vertices_inmem
tests: tests/basic_smoketest tests/bulksync_functional_test tests/dynamicdata_smoketest tests/test_dynamicedata_loader

echo:
	echo $(HEADERS)
clean:
	@rm -rf bin/*
	cd toolkits/collaborative_filtering/; make clean; cd ../../
	cd toolkits/parsers/; make clean; cd ../../
	cd toolkits/graph_analytics/; make clean; cd ../../

blocksplitter: src/preprocessing/blocksplitter.cpp $(HEADERS)
	$(CPP) $(CPPFLAGS) src/preprocessing/blocksplitter.cpp -o bin/blocksplitter $(LINKERFLAGS)

sharder_basic: src/preprocessing/sharder_basic.cpp $(HEADERS)
	@mkdir -p bin
	$(CPP) $(CPPFLAGS) src/preprocessing/sharder_basic.cpp -o bin/sharder_basic $(LINKERFLAGS)

example_apps/% : example_apps/%.cpp $(HEADERS)
	@mkdir -p bin/$(@D)
	$(CPP) $(CPPFLAGS) -Iexample_apps/ $@.cpp -o bin/$@ $(LINKERFLAGS) 

myapps/% : myapps/%.cpp $(HEADERS)
	@mkdir -p bin/$(@D)
	$(CPP) $(CPPFLAGS) -Imyapps/ $@.cpp -o bin/$@ $(LINKERFLAGS)

tests/%: src/tests/%.cpp $(HEADERS)
	@mkdir -p bin/$(@D)
	$(CPP) $(CPPFLAGS) src/$@.cpp -o bin/$@	$(LINKERFLAGS)


graphlab_als: example_apps/matrix_factorization/graphlab_gas/als_graphlab.cpp
	$(CPP) $(CPPFLAGS) example_apps/matrix_factorization/graphlab_gas/als_graphlab.cpp -o bin/graphlab_als $(LINKERFLAGS)

cf:
	cd toolkits/collaborative_filtering/; bash ./test_eigen.sh; 
	if [ $$? -ne 0 ]; then exit 1; fi
	cd toolkits/collaborative_filtering/; make 
cf_test:
	cd toolkits/collaborative_filtering/; make test; 
cfd:
	cd toolkits/collaborative_filtering/; make -f Makefile.debug

parsers:
	cd toolkits/parsers/; make
parsersd:
	cd toolkits/parsers/; make -f Makefile.debug
ga:
	cd toolkits/graph_analytics/; make
ta:
	cd toolkits/text_analysis/; make

docs: */**
	doxygen conf/doxygen/doxygen.config

######################Unicorn Specific (Do Not Change)###############
unicorn/% : unicorn/%.cpp $(HEADERS)
	@mkdir -p bin/$(@D)
	$(CPP) $(CPPFLAGS) -Iunicorn/ $@.cpp -o bin/$@ $(LINKERFLAGS)
#####################################################################
######################Unicorn Specific (Templates)################################################
swdebug: CPPFLAGS += -DSKETCH_SIZE=2000 -DK_HOPS=3 -DMEMORY -DPREGEN=10000 -DUSEWINDOW -DBASESKETCH -DDEBUG -g
swdebug: unicorn/main

sb: CPPFLAGS += -DSKETCH_SIZE=2000 -DK_HOPS=3 -DMEMORY -DPREGEN=10000 -g
sb: unicorn/main

######################Unicorn Toy Example################################################
toy:
	cd ../../data && mkdir -p train_toy
	number=0 ; while [ $$number -le 99 ] ; do \
		bin/unicorn/main filetype edgelist base ../../data/toy_data/base_train/base-toy-$$number.txt stream ../../data/toy_data/stream_train/stream-toy-$$number.txt decay 500 lambda 0.02 batch 2000 sketch ../../data/train_toy/sketch-toy-$$number.txt chunkify 1 chunk_size 50 ; \
		rm -rf ../../data/toy_data/base_train/base-toy-$$number.txt.* ; \
		rm -rf ../../data/toy_data/base_train/base-toy-$$number.txt_* ; \
		number=`expr $$number + 4` ; \
	done
	cd ../../data && mkdir -p test_toy
	number=300 ; while [ $$number -le 399 ] ; do \
		bin/unicorn/main filetype edgelist base ../../data/toy_data/base_test/base-attack-$$number.txt stream ../../data/toy_data/stream_test/stream-attack-$$number.txt decay 500 lambda 0.02 batch 2000 sketch ../../data/test_toy/sketch-attack-$$number.txt chunkify 1 chunk_size 50 ; \
		rm -rf ../../data/toy_data/base_test/base-attack-$$number.txt.* ; \
		rm -rf ../../data/toy_data/base_test/base-attack-$$number.txt_* ; \
		number=`expr $$number + 16` ; \
	done

INCFLAGS = -I/usr/local/include/ -I./src/

CPP = g++
CPPFLAGS = -std=c++11 -g -O3 $(INCFLAGS) -fopenmp -ffast-math -Wall -Wno-strict-aliasing -lpthread
CPPFLAGSPG = -std=c++11 -g -O3 $(INCFLAGS) -fopenmp -Wall -Wno-strict-aliasing -lpthread -pg
LINKERFLAGS = -lz
LINKERFLAGSPG = -lz -pg
DEBUGFLAGS = -g -ggdb $(INCFLAGS)
HEADERS=$(shell find . -name '*.hpp')


all: apps tests 
apps: example_apps/connectedcomponents example_apps/pagerank example_apps/pagerank_functional example_apps/communitydetection example_apps/unionfind_connectedcomps example_apps/stronglyconnectedcomponents example_apps/trianglecounting example_apps/randomwalks example_apps/minimumspanningforest
als: example_apps/matrix_factorization/als_edgefactors  example_apps/matrix_factorization/als_vertices_inmem
tests: tests/basic_smoketest tests/bulksync_functional_test tests/dynamicdata_smoketest tests/test_dynamicedata_loader

echo:
	echo $(HEADERS)
clean:
	@rm -rf bin/*
	cd toolkits/collaborative_filtering/; make clean; cd ../../
	cd toolkits/parsers/; make clean; cd ../../
	cd toolkits/graph_analytics/; make clean; cd ../../

blocksplitter: src/preprocessing/blocksplitter.cpp $(HEADERS)
	$(CPP) $(CPPFLAGS) src/preprocessing/blocksplitter.cpp -o bin/blocksplitter $(LINKERFLAGS)

sharder_basic: src/preprocessing/sharder_basic.cpp $(HEADERS)
	@mkdir -p bin
	$(CPP) $(CPPFLAGS) src/preprocessing/sharder_basic.cpp -o bin/sharder_basic $(LINKERFLAGS)

example_apps/% : example_apps/%.cpp $(HEADERS)
	@mkdir -p bin/$(@D)
	$(CPP) $(CPPFLAGS) -Iexample_apps/ $@.cpp -o bin/$@ $(LINKERFLAGS) 

myapps/% : myapps/%.cpp $(HEADERS)
	@mkdir -p bin/$(@D)
	$(CPP) $(CPPFLAGS) -Imyapps/ $@.cpp -o bin/$@ $(LINKERFLAGS)

tests/%: src/tests/%.cpp $(HEADERS)
	@mkdir -p bin/$(@D)
	$(CPP) $(CPPFLAGS) src/$@.cpp -o bin/$@	$(LINKERFLAGS)


graphlab_als: example_apps/matrix_factorization/graphlab_gas/als_graphlab.cpp
	$(CPP) $(CPPFLAGS) example_apps/matrix_factorization/graphlab_gas/als_graphlab.cpp -o bin/graphlab_als $(LINKERFLAGS)

cf:
	cd toolkits/collaborative_filtering/; bash ./test_eigen.sh; 
	if [ $$? -ne 0 ]; then exit 1; fi
	cd toolkits/collaborative_filtering/; make 
cf_test:
	cd toolkits/collaborative_filtering/; make test; 
cfd:
	cd toolkits/collaborative_filtering/; make -f Makefile.debug

parsers:
	cd toolkits/parsers/; make
parsersd:
	cd toolkits/parsers/; make -f Makefile.debug
ga:
	cd toolkits/graph_analytics/; make
ta:
	cd toolkits/text_analysis/; make

docs: */**
	doxygen conf/doxygen/doxygen.config

######################Unicorn Specific (Do Not Change)###############
unicorn/% : unicorn/%.cpp $(HEADERS)
	@mkdir -p bin/$(@D)
	$(CPP) $(CPPFLAGS) -Iunicorn/ $@.cpp -o bin/$@ $(LINKERFLAGS)
#####################################################################
######################Unicorn Specific (Templates)################################################
swdebug: CPPFLAGS += -DSKETCH_SIZE=2000 -DK_HOPS=3 -DMEMORY -DPREGEN=10000 -DUSEWINDOW -DBASESKETCH -DDEBUG -g
swdebug: unicorn/main

sb: CPPFLAGS += -DSKETCH_SIZE=2000 -DK_HOPS=3 -DMEMORY -DPREGEN=10000 -g
sb: unicorn/main

######################Unicorn Toy Example################################################
toy:
	cd ../../data && mkdir -p train_toy
	number=0 ; while [ $$number -le 99 ] ; do \
		bin/unicorn/main filetype edgelist base ../../data/toy_data/base_train/base-toy-$$number.txt stream ../../data/toy_data/stream_train/stream-toy-$$number.txt decay 500 lambda 0.02 batch 2000 sketch ../../data/train_toy/sketch-toy-$$number.txt chunkify 1 chunk_size 50 ; \
		rm -rf ../../data/toy_data/base_train/base-toy-$$number.txt.* ; \
		rm -rf ../../data/toy_data/base_train/base-toy-$$number.txt_* ; \
		number=`expr $$number + 4` ; \
	done
	cd ../../data && mkdir -p test_toy
	number=300 ; while [ $$number -le 399 ] ; do \
		bin/unicorn/main filetype edgelist base ../../data/toy_data/base_test/base-attack-$$number.txt stream ../../data/toy_data/stream_test/stream-attack-$$number.txt decay 500 lambda 0.02 batch 2000 sketch ../../data/test_toy/sketch-attack-$$number.txt chunkify 1 chunk_size 50 ; \
		rm -rf ../../data/toy_data/base_test/base-attack-$$number.txt.* ; \
		rm -rf ../../data/toy_data/base_test/base-attack-$$number.txt_* ; \
		number=`expr $$number + 16` ; \
	done

youtube:
	cd ../../data && mkdir -p train_youtube
	number=0 ; while [ $$number -le 99 ] ; do \
		bin/unicorn/main filetype edgelist base ../../data/youtube_data/base_train/base-youtube-$$number.txt stream ../../data/youtube_data/stream_train/stream-youtube-$$number.txt decay 500 lambda 0.02 batch 2000 sketch ../../data/train_youtube/sketch-youtube-$$number.txt chunkify 1 chunk_size 50 ; \
		rm -rf ../../data/youtube_data/base_train/base-youtube-$$number.txt.* ; \
		rm -rf ../../data/youtube_data/base_train/base-youtube-$$number.txt_* ; \
		number=`expr $$number + 1` ; \
	done
	cd ../../data && mkdir -p test_attack
	number=300 ; while [ $$number -le 399 ] ; do \
		bin/unicorn/main filetype edgelist base ../../data/attack_data/base_test/base-attack-$$number.txt stream ../../data/attack_data/stream_test/stream-attack-$$number.txt decay 500 lambda 0.02 batch 2000 sketch ../../data/test_attack/sketch-attack-$$number.txt chunkify 1 chunk_size 50 ; \
		rm -rf ../../data/attack_data/base_test/base-attack-$$number.txt.* ; \
		rm -rf ../../data/attack_data/base_test/base-attack-$$number.txt_* ; \
		number=`expr $$number + 1` ; \
	done

cnn:
	cd ../../data && mkdir -p train_cnn
	number=500 ; while [ $$number -le 599 ] ; do \
		bin/unicorn/main filetype edgelist base ../../data/cnn_data/base_train/base-cnn-$$number.txt stream ../../data/cnn_data/stream_train/stream-cnn-$$number.txt decay 500 lambda 0.02 batch 2000 sketch ../../data/train_cnn/sketch-cnn-$$number.txt chunkify 1 chunk_size 50 ; \
		rm -rf ../../data/cnn_data/base_train/base-cnn-$$number.txt.* ; \
		rm -rf ../../data/cnn_data/base_train/base-cnn-$$number.txt_* ; \
		number=`expr $$number + 1` ; \
	done

download:
	cd ../../data && mkdir -p train_download
	number=400 ; while [ $$number -le 499 ] ; do \
		bin/unicorn/main filetype edgelist base ../../data/download_data/base_train/base-download-$$number.txt stream ../../data/download_data/stream_train/stream-download-$$number.txt decay 500 lambda 0.02 batch 2000 sketch ../../data/train_download/sketch-download-$$number.txt chunkify 1 chunk_size 50 ; \
		rm -rf ../../data/download_data/base_train/base-download-$$number.txt.* ; \
		rm -rf ../../data/download_data/base_train/base-download-$$number.txt_* ; \
		number=`expr $$number + 1` ; \
	done

gmail:
	cd ../../data && mkdir -p train_gmail
	number=100 ; while [ $$number -le 199 ] ; do \
		bin/unicorn/main filetype edgelist base ../../data/gmail_data/base_train/base-gmail-$$number.txt stream ../../data/gmail_data/stream_train/stream-gmail-$$number.txt decay 500 lambda 0.02 batch 2000 sketch ../../data/train_gmail/sketch-gmail-$$number.txt chunkify 1 chunk_size 50 ; \
		rm -rf ../../data/gmail_data/base_train/base-gmail-$$number.txt.* ; \
		rm -rf ../../data/gmail_data/base_train/base-gmail-$$number.txt_* ; \
		number=`expr $$number + 1` ; \
	done

vgame:
	cd ../../data && mkdir -p train_vgame
	number=200 ; while [ $$number -le 299 ] ; do \
		bin/unicorn/main filetype edgelist base ../../data/vgame_data/base_train/base-vgame-$$number.txt stream ../../data/vgame_data/stream_train/stream-vgame-$$number.txt decay 500 lambda 0.02 batch 2000 sketch ../../data/train_vgame/sketch-vgame-$$number.txt chunkify 1 chunk_size 50 ; \
		rm -rf ../../data/vgame_data/base_train/base-vgame-$$number.txt.* ; \
		rm -rf ../../data/vgame_data/base_train/base-vgame-$$number.txt_* ; \
		number=`expr $$number + 1` ; \
	done
