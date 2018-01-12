#include <stdio.h>
#include <math.h>

/* a halo topologiajat leiro definiciok */
#define NUM_LAYERS  4 //retegek szama (a bemeneti es a kimeneti reteget is beleertve)
#define NUM_L0      2 //bemenetek szama
#define NUM_L1      4 //1. rejtett retegbeli neuronok szama
#define NUM_L2      3 //2. rejtett retegbeli neuronok szama
#define NUM_L3      1 //kimenetek szama

/* az egyes retegekben talalhato neuronok kimenetei */
double l0[NUM_L0];
double l1[NUM_L1];
double l2[NUM_L2];
double l3[NUM_L3];

/* az egyes retegek meretei */
unsigned layerSizes[NUM_LAYERS]={NUM_L0,NUM_L1,NUM_L2,NUM_L3};

/* az egyes retegek kozti sulyok
   a wij vektor a Wij matrix egymas utan fuzott oszlopait tartalmazza (lj=Wij*li)
   a +1 erteku biasokhoz tartozo sulyok a vektor vegen vannak                               */
double w01[(NUM_L0+1)*NUM_L1]={0.142977, -0.050683, -2.068843, 1.812799, -2.798264, -2.847919, -2.461414, -3.109087, -2.790667, 1.446120, 0.626038, 2.461196};
double w12[(NUM_L1+1)*NUM_L2]={-0.226871, -1.047031, -0.256673, 2.127523, -0.665378, -1.168340, -0.017395, 2.477330, -0.548639, -1.837669, -0.012256, -1.985544, 1.807566, -0.014886, -1.762980};
double w23[(NUM_L2+1)*NUM_L3]={3.257070, -3.610464, 1.142909, 1.394518};

/* pointerek a retegek es a sulyok tombjeire */
double*  layers[NUM_LAYERS  ]={ l0,  l1,  l2,  l3 };
double* weights[NUM_LAYERS-1]={   w01, w12, w23   };

/* aktivacios fuggveny */
double activation(double x){
	return 2.0/(1+exp(-2*x))-1;
}

/* a halo mukodtetese a megadott bemenetre */
void propagateForward(const double* in, double* out){
	unsigned i, j, k;
	for(i=0;i<layerSizes[0];i++) layers[0][i]=in[i];
	for(i=1;i<NUM_LAYERS;i++){
		for(j=0;j<layerSizes[i];j++){
			layers[i][j]=0;
			for(k=0;k<layerSizes[i-1];k++) layers[i][j]+=weights[i-1][j+k*layerSizes[i]]*layers[i-1][k];
			layers[i][j]=activation(layers[i][j]+weights[i-1][layerSizes[i-1]*layerSizes[i]+j]);
		}
	}
	for(i=0;i<layerSizes[NUM_LAYERS-1];i++) out[i]=layers[NUM_LAYERS-1][i];
}

int main(){
	double in[2], out[1];
	while(1){
		printf("Kerem a ket bemenetet vesszovel elvalaszva: ");
		scanf("%lf,%lf",in,in+1);
		propagateForward(in,out);
		printf("\nKimenet: %lf\n\n\n",out[0]);
	}
	return 0;
}
