#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "cnn_parameters.h"

double relu(double in){
	return (in>0)?in:0;
}

void softmax(const double *in, double *out, unsigned size){
	unsigned i;
	double sum=0;
	for(i=0;i<size;i++) sum+=exp(in[i]);
	for(i=0;i<size;i++) out[i]=exp(in[i])/sum;
}

double max4(double a, double b, double c, double d){
	return fmax(fmax(fmax(a,b),c),d);
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

unsigned propagateForward(const double x[28][28]){
	int fin, fout, r, c, i, j;
	double conv1[32][28][28], pool1[32][14][14], conv2[64][14][14], pool2[64][7][7], fc1[1024], fc2[10];
	/* 1: konvolucios reteg */
	for(fout=0;fout<32;fout++)
		for(r=0;r<28;r++)
			for(c=0;c<28;c++)
				conv1[fout][r][c]=b_conv1[fout];
	for(fout=0;fout<32;fout++)
		for(r=0;r<28;r++)
			for(c=0;c<28;c++)
				for(i=0;i<5;i++)
					for(j=0;j<5;j++)
						if((r+i-2)<28 && (r+i-2)>=0 && (c+j-2)<28 && (c+j-2)>=0)
							conv1[fout][r][c]+=x[r+i-2][c+j-2]*W_conv1[0][fout][i][j];
	for(fout=0;fout<32;fout++)
		for(r=0;r<28;r++)
			for(c=0;c<28;c++)
				conv1[fout][r][c]=relu(conv1[fout][r][c]);
	/* 2: maxpool */
	for(fout=0;fout<32;fout++)
		for(r=0;r<14;r++)
			for(c=0;c<14;c++)
				pool1[fout][r][c]=max4(conv1[fout][2*r][2*c],conv1[fout][2*r][2*c+1],conv1[fout][2*r+1][2*c],conv1[fout][2*r+1][2*c+1]);
	/* 3: konvolucios reteg */
	for(fout=0;fout<64;fout++)
		for(r=0;r<14;r++)
			for(c=0;c<14;c++)
				conv2[fout][r][c]=b_conv2[fout];
	for(fin=0;fin<32;fin++)
		for(fout=0;fout<64;fout++)
			for(r=0;r<14;r++)
				for(c=0;c<14;c++)
					for(i=0;i<5;i++)
						for(j=0;j<5;j++)
							if((r+i-2)<14 && (r+i-2)>=0 && (c+j-2)<14 && (c+j-2)>=0)
								conv2[fout][r][c]+=pool1[fin][r+i-2][c+j-2]*W_conv2[fin][fout][i][j];
	for(fout=0;fout<64;fout++)
		for(r=0;r<14;r++)
			for(c=0;c<14;c++)
				conv2[fout][r][c]=relu(conv2[fout][r][c]);
	/* 4: maxpool */
	for(fout=0;fout<64;fout++)
		for(r=0;r<7;r++)
			for(c=0;c<7;c++)
				pool2[fout][r][c]=max4(conv2[fout][2*r][2*c],conv2[fout][2*r][2*c+1],conv2[fout][2*r+1][2*c],conv2[fout][2*r+1][2*c+1]);
	/* 5: teljesen osszekotott reteg */
	for(i=0;i<1024;i++){
		fc1[i]=b_fc1[i];
		for(j=0;j<7*7*64;j++) fc1[i]+=pool2[j%64][(j/64)/7][(j/64)%7]*W_fc1[j][i];
		fc1[i]=relu(fc1[i]);
	}
	/* 6: teljesen osszekotott reteg */
	for(i=0;i<10;i++){
		fc2[i]=b_fc2[i];
		for(j=0;j<1024;j++) fc2[i]+=fc1[j]*W_fc2[j][i];
	}
	softmax(fc2,fc2,10);
	return argmax(fc2,10);
}

int main(void){
	double input[28][28];
	FILE *fil;
	unsigned i, j, temp;
	fil=fopen("input.txt","rt");
	if(fil==NULL) return 0;
	for(i=0;i<28;i++)
		for(j=0;j<28;j++){
			fscanf(fil,"%u",&temp);
			input[i][j]=temp/255.0;
		}
	fclose(fil);
	printf("%u\n\n",propagateForward(input));
	getchar();
	return 0;
}
