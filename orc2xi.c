#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <math.h>
#include <ctype.h>
#include <unistd.h>


char zero_out(char *input, int num);
char get_size(FILE *fp); double pch2num(double pch);
double num2pch(int number);

int main(int argc, char **argv){

/* user-input variables */
float version = 1.01;
char *orc = NULL;
int samples = 1;
char note[7];
int keypos = 48; 
int increment = 12;
char *dur = ".5";

int c;
opterr = 0;

while ((c = getopt (argc, argv, "i:s:k:n:d:")) != -1)
	switch(c){
		case 'i':
			orc = optarg;
			break;
		case 's':
			samples = atoi(optarg);
			break;
		case 'k':
			keypos = atoi(optarg);
			break;
		case 'n':
			increment = atoi(optarg);
			break;
		case 'd':
			dur = optarg;
			break;
		case '?':
			if (optopt == 'i')
				fprintf (stderr, "Option -%c requires an argument. \n", optopt);
			else if (isprint (optopt))
				fprintf (stderr, "Unknown option `-%c'. \n", optopt);
			else
				fprintf (stderr, "Unknown option character `\\x%x' .\n", optopt);
			return 1;
		default:
			abort();
	}

if(orc == NULL){

printf("ORC2XI VERSION %g\nInvalid syntax. Example:\norc2xi -i ORC -s SAMPS -k KEYPOS -n INCR -d DUR\n", version);

return 0;
}


/**************/
/* RENDER ORC */
/**************/

int j;
int i;
double pch;

char x;

/* automatically add headerfile with proper sample rate and number of channels */

FILE *copy = fopen("orc2xi.orc", "w");
FILE *orc_file = fopen(orc, "r");
fprintf(copy, "sr = 44100\nksmps = 1\nnchnls = 1\n0dbfs = 1\n");
while(1){
if(feof(orc_file)){ break;}
x = fgetc(orc_file);
fputc(x, copy);
}
fclose(copy);
fclose(orc_file);


for (i = 0; i < samples; i++){
	char out[20];
	pch = num2pch(keypos + increment*(i));
	sprintf(note, "%g", pch);
	sprintf(out, "%i", i);
	FILE *sco = fopen("out.sco", "w");
	fprintf(sco, "i 1 0 %s %s 0.6", dur, note);
	fclose(sco);
	char *score = "out.sco";
	//char *wav;
	//sprintf(wav, "%i ", out);
	char cmd[100];
	//sprintf(cmd, "csound -h -o %s %s %s", out, orc, score);
	strcpy(cmd, "csound -d -h -o ");
	strcat(cmd, out);
	strcat(cmd, " ");
	strcat(cmd, "orc2xi.orc");
	strcat(cmd, " ");
	strcat(cmd, score);
	system(cmd);
	//pch = num2pch(pch2num(atof(note)) + increment);
}

/******************/
/* HEADER SECTION */
/******************/	

char name[50];
strcpy(name, orc);
char xiname[54];
strcpy(xiname, name);
strcat(xiname, ".xi");
FILE *fp = fopen(xiname, "w");
char *extended = "Extended Instrument: ";
char *tracker = "FastTracker V2.00   ";
fprintf(fp, "%s%-22s%c%s%c%c", 
		extended,
		name,
		0x1a,
		tracker,
		0x02,
		0x01);
/*XI information*/
char keymappings[96];
char volenvs[48];
char panenvs[48];
char panpoints = 2;
char volpoints = 2;
char volsuspoint = 0;
char vollpstart = 0;
char vollpend = 1;
char pansuspnt = 0;
char panlpstrt = 0;
char panlpend = 1;
char voltype = 0;
char pantype = 0;
char vibtype = 0;
char vibsweep = 0;
char vibdepth = 0;
char vibrate = 0;
char volfade[2] = {255, 127};
char reserve[22];
char numsamps = 1;

/*Zero out the arrays*/
zero_out(keymappings, 96);

/*Map out samples*/
int key_start = keypos;
for(i = 0; i < samples; i++){
	for(j = 0; j < increment; j++){
		keymappings[key_start+j] = i;
	}
	key_start += increment;
}

/*fill out upper register with highest sample*/
for(i = key_start; i < 96; i++){
keymappings[i] = samples - 1;
}

zero_out(volenvs, 48);
zero_out(panenvs, 48);
zero_out(reserve, 22);

/*Write to XI*/
printf("Writing orc header...");
for(i = 0; i < 96; i++){
fputc(keymappings[i], fp);
}

for(i = 0; i < 48; i++){
fputc(volenvs[i], fp);
}

for(i = 0; i < 48; i++){
fputc(panenvs[i], fp);
}
fputc(panpoints, fp);
fputc(volpoints, fp);
fputc(volsuspoint, fp);
fputc(vollpstart, fp);
fputc(vollpend, fp);
fputc(pansuspnt, fp);
fputc(panlpstrt, fp);
fputc(panlpend, fp);
fputc(voltype, fp);
fputc(pantype, fp);
fputc(vibtype, fp);
fputc(vibsweep, fp);
fputc(vibdepth, fp);
fputc(vibrate, fp);
fputc(volfade[0], fp);
fputc(volfade[1], fp);

for(i = 0; i < 22; i ++){
	fputc(reserve[i], fp);
}
//fputc(numsamps, fp);
fprintf(fp, "%c", samples);
fputc(0, fp);
printf("Done!\n");
/****************/
/*SAMPLE SECTION*/
/****************/
printf("Writing sample headers....");
	FILE *sample;
	char fname[2];
	int size[samples];
for(i = 0; i < samples; i++){
	sprintf(fname, "%i", i);
	sample = fopen(fname, "r");

	/*Sample Information*/

	/*find sample size */
	fseek(sample, 0L, SEEK_END);
	size[i] = ftell(sample);

	/*Size conversion */
	int byte1 = size[i] % 0x100;
	int byte2 = ((size[i]-byte1) % 0x10000)/0x100;
	int byte3 = ((((size[i]-byte1)-byte2*0x100)) % 0x1000000)/0x10000;
	int byte4 = (((((size[i]-byte1)-byte2*0x100)-byte3*0x10000)) % 0x100000000)/0x100000;


	char smp_vol = 0x40;
	char smp_ft = 0;
	char smp_type = 0x10;
	char smp_pan = 0x80;
	//char smp_note = 0x11;
	int smp_note = 77 - keypos - increment*i; 
	char smp_name[22];
	sprintf(smp_name,"Sample %i", i+1);
	/* Write Sample Header */
	fprintf(fp,"%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c%-22s",
			  byte1,byte2,byte3,byte4,
			  0x0,0x0,0x0,0x0,
			  byte1,byte2,byte3,byte4,
			  smp_vol,
			  smp_ft,
			  smp_type,
			  smp_pan,
			  smp_note,
			  0x0,
			  smp_name
			  );
	fclose(sample);
}
printf("Done!\n");

/*Encode sample data using sigma delta and write xi*/
printf("Encoding samples and writing to xi...");
for(i = 0; i < samples; i++){
	sprintf(fname, "%i", i);
	sample = fopen(fname, "r");
	
	fseek(sample, 0L, SEEK_END);
	size[i] = ftell(sample);
	
	fseek(sample, 0, SEEK_SET);
	int c1;
	int c2;
	int value;
	int delta = 0;
	int original;

	for(j = 0; j < (size[i]/2); j++){
		c1 = fgetc(sample);
		c2 = fgetc(sample);
		value = c2*0x100 + c1;
		original = value;
		value -= delta;
		if(value < 0){
			value += 0x10000;
		}
		delta = original;
		c1 = value % 0x100;
		c2 = (value-c1)/0x100;
		fputc(c1, fp);
		fputc(c2, fp);
	}
	fclose(sample);
}
fclose(fp);
printf("Done!\n");
printf("Cleaning up...");
for(i = 0; i < samples; i++){
char cmd[7];
sprintf(cmd, "rm %i", i);
system(cmd);
}
system("rm out.sco");
system("rm orc2xi.orc");
printf("Done!\n");
printf("%s created\n", xiname);
return 0;
}

char zero_out(char *input, int num){
int i;
for(i = 0; i < num; i++){
	input[i] = 0;
}
return 0;
}

double pch2num(double pch){
	double octave = floor(pch);
	double note = (pch - octave)*100;
	int number = (note)+((octave-4)*12);
	//int number = note;
	return number;
}
double num2pch(int number){
	int octave = (number/12)+4;
	double note = (number % 12)*0.01;
	double pch = octave + note;
	return pch;
}
