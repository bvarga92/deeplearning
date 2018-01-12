#include <stdio.h>
#include <stdlib.h>
#include <math.h>

typedef struct{
	unsigned numLayers;
	unsigned* layerSizes;
	double** layers;
	double** weights;
	double (*activation)(double);
} MLP_t;

double mlpActLinear(double x){return x;}
double mlpActSigmoid(double x){return 2.0/(1+exp(-2*x))-1;}

void mlpCreate(MLP_t* net, unsigned numLayers, char activation){
	net->numLayers=numLayers;
	net->layerSizes=malloc(numLayers*sizeof(unsigned));
	net->layers=malloc(numLayers*sizeof(double*));
	net->weights=malloc((numLayers-1)*sizeof(double*));
	switch(activation){
		case 'L': net->activation=mlpActLinear;  break;
		case 'S': net->activation=mlpActSigmoid; break;
		default : net->activation=mlpActSigmoid; break;
	}
}

void mlpAddLayer(MLP_t* net, unsigned index, unsigned size){
	if(index>=net->numLayers) return;
	net->layerSizes[index]=size;
	net->layers[index]=malloc(size*sizeof(double));
}

void mlpAddWeight(MLP_t* net, unsigned indexFrom, const double *w){
	unsigned i, size;
	if(indexFrom>=net->numLayers-1) return;
	size=(net->layerSizes[indexFrom]+1)*(net->layerSizes[indexFrom+1]);
	net->weights[indexFrom]=malloc(size*sizeof(double));
	for(i=0;i<size;i++) net->weights[indexFrom][i]=w[i];
}

void mlpDestroy(MLP_t* net){
	unsigned i;
	for(i=0;i<net->numLayers;i++) free(net->layers[i]);
	for(i=0;i<net->numLayers-1;i++) free(net->weights[i]);
	free(net->layers);
	free(net->weights);
	free(net->layerSizes);
}

void mlpPropagateForward(MLP_t* net, const double* in, double* out){
	unsigned i, j, k;
	for(i=0;i<net->layerSizes[0];i++) net->layers[0][i]=in[i];
	for(i=1;i<net->numLayers;i++){
		for(j=0;j<net->layerSizes[i];j++){
			net->layers[i][j]=0;
			for(k=0;k<net->layerSizes[i-1];k++) net->layers[i][j]+=net->weights[i-1][j+k*net->layerSizes[i]]*net->layers[i-1][k];
			net->layers[i][j]=net->activation(net->layers[i][j]+net->weights[i-1][net->layerSizes[i-1]*net->layerSizes[i]+j]);
		}
	}
	for(i=0;i<net->layerSizes[net->numLayers-1];i++) out[i]=net->layers[net->numLayers-1][i];
}

int main(){
	double in[2], out[1];
	unsigned i;
	MLP_t net;
	double w01[12]={0.142977, -0.050683, -2.068843, 1.812799, -2.798264, -2.847919, -2.461414, -3.109087, -2.790667, 1.446120, 0.626038, 2.461196};
	double w12[15]={-0.226871, -1.047031, -0.256673, 2.127523, -0.665378, -1.168340, -0.017395, 2.477330, -0.548639, -1.837669, -0.012256, -1.985544, 1.807566, -0.014886, -1.762980};
	double w23[4]={3.257070, -3.610464, 1.142909, 1.394518};
	mlpCreate(&net,4,'S'); //MLP halo 4 reteggel, szigmoid aktivacios fuggvennyel
	mlpAddLayer(&net,0,2); //bemeneti reteg
	mlpAddLayer(&net,1,4); //1. rejtett reteg
	mlpAddLayer(&net,2,3); //2. rejtett reteg
	mlpAddLayer(&net,3,1); //kimeneti reteg
	mlpAddWeight(&net,0,w01); // l0 --> l1 sulyok
	mlpAddWeight(&net,1,w12); // l1 --> l2 sulyok
	mlpAddWeight(&net,2,w23); // l2 --> l3 sulyok
	for(i=0;i<10;i++){
		printf("Kerem a ket bemenetet vesszovel elvalaszva: ");
		scanf("%lf,%lf",in,in+1);
		mlpPropagateForward(&net,in,out);
		printf("\nKimenet: %lf\n\n\n",out[0]);
	}
	mlpDestroy(&net); //felszabaditas
	return 0;
}
