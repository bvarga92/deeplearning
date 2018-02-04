#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "regr_parameters.h"

double input[784]={
	#include "input.txt"
};

void softmax(const double *in, double *out, unsigned size){
	unsigned i;
	double sum=0;
	for(i=0;i<size;i++) sum+=exp(in[i]);
	for(i=0;i<size;i++) out[i]=exp(in[i])/sum;
}

unsigned argmax(const double *v, unsigned size){
	double m;
	unsigned mi, i;
	if(size==0) return 0;
	m=v[0];
	mi=0;
	for(i=1;i<size;i++)
		if(v[i]>m){
			m=v[i];
			mi=i;
		}
	return mi;
}

unsigned propagateForward(const double *x){
	unsigned i, j;
	double temp[10];
	for(i=0;i<10;i++){
		temp[i]=b[i];
		for(j=0;j<784;j++) temp[i]+=x[j]*W[j][i];
	}
	softmax(temp,temp,10);
	return argmax(temp,10);
}

int main(void){
	unsigned i;
	for(i=0;i<784;i++) input[i]/=255.0;
	printf("%u",propagateForward(input));
	return 0;
}
