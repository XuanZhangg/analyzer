/*
 *
 * Author: Xueyuan Han <hanx@g.harvard.edu>
 *
 * Copyright (C) 2018 Harvard University
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2, as
 * published by the Free Software Foundation; either version 2 of the License,
 * or (at your option) any later version.
 *
 */
#include "include/histogram.hpp"
#include <math.h>

Histogram* Histogram::histogram;

Histogram* Histogram::get_instance() {
	if (!histogram) 
		histogram = new Histogram();
	return histogram;
}

Histogram::~Histogram(){
	this->size = 0;
	delete histogram;
}

/*!
 * @brief Insert @label to the histogram_map if it does not exist; otherwise, update the mapped "cnt" value.
 *
 * This function is used in the base graph for later sketch creation.
 * When creating sketch, we do not change t, i.e., decay is not taken into the account.
 *
 */
void Histogram::insert_label(unsigned long label) {
	std::pair<std::map<unsigned long, struct hist_elem>::iterator, bool> rst;
	struct hist_elem new_elem;
	new_elem.cnt = 1;
	for (int i = 0; i < SKETCH_SIZE; i++) {
		new_elem.r[i] = gamma_dist(r_generator);
		new_elem.beta[i] = uniform_dist(beta_generator);
		new_elem.c[i] = gamma_dist(c_generator);
	}
	rst = this->histogram_map.insert(std::pair<unsigned long, struct hist_elem>(label, new_elem));
	if (rst.second == false) {
#ifdef DEBUG
		logstream(LOG_DEBUG) << "The label " << label << " is already in the map. Updating the value only." << std::endl;
#endif
		((rst.first)->second).cnt++;
	} else {
		this->size++;
	}
	return;
}

/*!
 * @brief Insert @label to the histogram_map if it does not exist; otherwise, update the mapped "cnt" value and the sketch.
 *
 * This function is used in the streaming graph for sketch updates.
 * We decay every element in the histogram every DECAY edges.
 *
 */
void Histogram::update(unsigned long label) {
	this->t++;
	/* Decay first if needed. */
	if (this->t >= DECAY) {
		std::map<unsigned long, struct hist_elem>::iterator it;
		for (it = this->histogram_map.begin(); it != this->histogram_map.end(); it++) {
			(it->second).cnt *= pow(M_E, -LAMBDA); /* M_E is defined in <cmath>. */
		}
		for (int i = 0; i < SKETCH_SIZE; i++) {
			hash[i] *= pow(M_E, -LAMBDA);
		}
		this->t = 0; /* Reset this timer. */
	}

	/* Now we add the new element or update the existing element. */
	std::pair<std::map<unsigned long, struct hist_elem>::iterator, bool> rst;
	struct hist_elem new_elem;
	new_elem.cnt = 1;
	for (int i = 0; i < SKETCH_SIZE; i++) {
		new_elem.r[i] = gamma_dist(r_generator);
		new_elem.beta[i] = uniform_dist(beta_generator);
		new_elem.c[i] = gamma_dist(c_generator);
	}
	rst = this->histogram_map.insert(std::pair<unsigned long, struct hist_elem>(label, new_elem));
	if (rst.second == false) {
#ifdef DEBUG
		logstream(LOG_DEBUG) << "The label " << label << " is already in the map. Updating the sketch and its hash." << std::endl;
#endif
		((rst.first)->second).cnt++;
	} else {
		this->size++;
	}

	/* Now we update the hash if needed. */
	for (int i = 0; i < SKETCH_SIZE; i++) {
		/* Compute the new hash value a. */
		double y = pow(M_E, log(((rst.first)->second).cnt) - ((rst.first)->second).r[i] * ((rst.first)->second).beta[i]);
		double a = ((rst.first)->second).c[i] / (y * pow(M_E, ((rst.first)->second).r[i]));

		if (a < this->hash[i]) {
			this->hash[i] = a;
			this->sketch[i] = (rst.first)->first;
		}
	}

	return;
}

/*!
 * @brief Create (and initialize) a sketch after the base graph has been proceed by GraphChi.
 *
 */
void Histogram::create_sketch() {
	for (int i = 0; i < SKETCH_SIZE; i++) {
		/* Compute the hash value a. */
		std::map<unsigned long, struct hist_elem>::iterator it = this->histogram_map.begin();
		double y = pow(M_E, log((it->second).cnt) - (it->second).r[i] * (it->second).beta[i]);
		double a_i = (it->second).c[i] / (y * pow(M_E, (it->second).r[i]));
		unsigned long s_i = it->first;
		for (it = this->histogram_map.begin(); it != this->histogram_map.end(); it++) {
			y = pow(M_E, log((it->second).cnt) - (it->second).r[i] * (it->second).beta[i]);
			double a = (it->second).c[i] / (y * pow(M_E, (it->second).r[i])); 
			if (a < a_i) {
				a_i = a;
				s_i = it->first;
			}
		}
		this->sketch[i] = s_i;
		this->hash[i] = a_i;
	}
}

void Histogram::get_lock() {
	this->histogram_map_lock.lock();
}

void Histogram::release_lock(){
	this->histogram_map_lock.unlock();
}

/*!
 * @brief Remove @label from the histogram_map.
 *
 */
// void Histogram::remove_label(unsigned long label) {
// 	std::map<unsigned long, int>::iterator it;
// 	it = this->histogram_map.find(label);
// 	if (it != this->histogram_map.end()) {
// 		it->second--;
// 		if (it->second == 0){
// 			this->size--;
// 		}
// 	}
// #ifdef DEBUG
// 	else {
// 		logstream(LOG_ERROR) << "Decrement histogram element count failed! The label " << label << " should have been in the histogram, but it is not." << std::endl;		
// 	}
// #endif

// 	return;
// }

void Histogram::record_sketch(FILE* fp) {
	for (int i = 0; i < SKETCH_SIZE; i++) {
		fprintf(fp,"%lu ", this->sketch[i]);
	}
	fprintf(fp, "\n");
	return;
}

/*!
 * @brief Print the histogram map for debugging.
 *
 */
void Histogram::print_histogram() {
	std::map<unsigned long, struct hist_elem>::iterator it;
	logstream(LOG_DEBUG) << "Printing histogram map to the console..." << std::endl;
	for (it = this->histogram_map.begin(); it != this->histogram_map.end(); it++)
		logstream(LOG_DEBUG) << "[" << it->first << "]->" << (it->second).cnt << "  ";
	return;
}