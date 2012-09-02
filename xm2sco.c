/*

XM2SCO v. 2.02

OUR TO-DO LIST:
1. create note c-struct. instead of using multiple arrays.
2. make an option that will render a sct file. This will be read by my other program SCORT, which will automatically sort the score into chronological order.
NOTE: if I am thinking of this correctly, the scruct will have an option called "linepos" 
3. in makestems, generate a python file which will automatically render the stems

DEAR PAUL,
SCORT SUCKS. WHY DID YOU... WHY?
-future paul
*/

#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
/* what our struct will look like. later we will implement it */

struct NOTE {
	int ins;
	float time;
	float dur;
	float pch;
	float amp;
	long loc;
};

void writesco(FILE *score, int instr, float time,  float dur, float pch, float amp); //write i-statement to file
float pchconv(int note); //convert hex to pch notation
int readhex(FILE *file, int loc); //read place in file
int readword(FILE *file, int loc); //read word in file
void writepattern(int pattern, float *time, int *patlen, int *patloc, int numchan, 
FILE *file, FILE *sco, float speed, struct NOTE *track, 
int song_count, int songlen, int *prevnote, int *noteoff, 
int ismulti, long *numlines, int renderscort, FILE *scort); //write pattern to file
void makestems(char *sco_filename, int numins);


int main(int argc, char **argv) {
     //load up songs
     float version = 2.02; //let people know what version it is
     char *filename = NULL;
     char *scorename = NULL;
	
	int renderscort = 0;
     int isverbose = 0;
     int ismulti = 0;
     int printtempo = 0;
     int c;
     opterr = 0;

     while ((c = getopt (argc, argv, "mvi:o:ts")) != -1)
          switch(c){
               case 'v':
                    isverbose = 1;
                    break;
               case 'm':
                    ismulti = 1;
                    break;
               case 'i':
                   filename = optarg;
                    break;
               case 'o':
                   scorename = optarg;
                    break;
               case 't':
                    printtempo = 1;
                    break;
               case 's':
                    renderscort = 1;
                    break;
               case '?':
                    if (optopt == 'o' || optopt == 'i')
                         fprintf (stderr, "Option -%c requires an argument. \n", optopt);
                    else if (isprint (optopt))
                         fprintf (stderr, "Unknown option `-%c'. \n", optopt);
                    else
                         fprintf (stderr, "Unknown option character `\\x%x' .\n", optopt);
                    return 1;
               default:
                    abort();
          }
      
     if(filename == NULL || scorename == NULL){
          printf("XM2SCO VERSION %f \nInvalid syntax for xm2sco. Bare syntax is: \n xm2sco -i XM_FILE -o SCORE_FILE\n\n\
Other flags that work are:\n\
-v = verbose mode. will print pattern locations and names as comments in score. \n\
-m = multiscore mode. will print each instrument in a separate sco file.\n\
-t = use tempo of XM file to make a tempo t-statement in the beginning of the score\n\
-s = render a scort file. SCORT is an experiment multiscore sorting utility. do not use. \n", version);
          return 0;
     }else if(ismulti && (isverbose || printtempo)){
          printf("you cannot render multiple score files with verbose flag or tempo flag ON\n");
          return 0;
     }
     int i;
     int j;
     
     FILE *file = fopen(filename, "r");
     int numins = readhex(file, 0x48); //if there are multiple score files, we need to know instrument #
     FILE *sco = fopen(scorename, "w");
	char scortname[50];
	sprintf(scortname, "%s.sct", scorename);
	FILE *scort = fopen("temp.sct", "wb");
     
     //get XM song info
     int bpm = readhex(file, 0x4e); //when implemented, readhex(0x4e)
     int numpat = readhex(file, 0x46);
     int numchan = readhex(file, 0x44);
     int songlen = readhex(file, 0x40);
     float globaltime = 0;
     float speed = readhex(file, 0x4c) * .25/6.0;
	long numlines = 0; //total number orch lines
     //float speed = .25;
     printf("XM2SCO version %f\n", version); 
     printf("BPM: %d\n", bpm); 
     printf("Number of Patterns: %d\n", songlen); 
     printf("Number of Channels: %d\n", numchan); 
     printf("Song Length: %d\n", songlen); 
     printf("Number of Instruments: %d\n", numins); 

     int patloc[numpat];
     patloc[0] = 0x150;
     int patlen[numpat];
     
     //initialize pattern lengths and locations in file
     printf("Initializing pattern %d lengths and locations\n", patloc[0] + 7);
     for(i = 0; i < numpat; i++){
          patlen[i] = readword(file, (patloc[i] + 7));
          patloc[i+1] = (patloc[i] + patlen[i] + 9);
     }

     printf("more initializing\n");
     //initialize duration, track, patter, prevnote
     int prevnote[numchan];
	struct NOTE track[numchan];
     int noteoff[numchan];

     for(i = 0; i < numchan; i++){
          prevnote[i] = 0;
          noteoff[i] = -1;
		//zero out notes
		track[i].ins = 0;
		track[i].time = 0;
		track[i].dur = 0;
		track[i].pch = 0;
		track[i].amp = 0;
		track[i].loc = 0;
     }

     int song_count = 0; //show how many patterns into the song the program is at. when song count = songlen, write last line to file
     printf("writing song tempo\n");
     //write song tempo
     if(printtempo){
          fprintf(sco, "t 0 %d\n", bpm);
     }
     //read pattern table
     printf("Reading pattern table\n");
     int pattern_place = 0x50; //start location of the pattern
     int pat;

	//write number of instruments in scort file, if flag enabled
     for (i = 0; i < songlen; i++){
     pat = readhex(file, pattern_place + i);
     if(isverbose){
               fprintf(sco,";Pattern %d\n",pat);
          }
     song_count += 1;
     writepattern(pat, &globaltime, patlen, patloc, numchan, file, sco, speed, track, song_count, songlen, prevnote, noteoff, ismulti, &numlines, renderscort, scort);
     globaltime += speed;
     }
	if(renderscort){
		fclose(scort);
		scort = fopen("temp.sct", "r");
		FILE *scorter = fopen(scortname, "w");
		char c;
		fwrite(&numlines, sizeof(long), 1, scorter);
		fwrite(&numins, sizeof(int), 1, scorter);
		rewind(scort);
		int x;
		while(1){
			c = fgetc(scort);
			if(feof(scort)){
					break;
					}
			putc(c,scorter);
			printf("%c\n", c); 
		}
		fclose(scorter);
	}
     fclose(file); 
     fclose(sco);
	
	printf("there are %i lines here\n", (int)numlines);
	fclose(scort);
	remove("temp.sct");
     if(ismulti){
          printf("making %d  stems...\n", numins);
          makestems(scorename, numins);
     }
     return 0;
}


float pchconv(int note){
     note -= 1;
     int octave = (note/12)+4;
     int list = note%12;
     float semi[] = {.00, .01, .02, .03, .04, .05, .06, .07, .08, .09, .10, .11};
     return (float)octave + semi[list];
}
void writesco(FILE *score, int instr, float time, float dur, float pch, float amp){
     fprintf(score, "i %d %g %g %.2f %g\n", instr, time, dur, pch, amp);
     //printf("\ni %d %g %g %.2f %g\n", instr, time, dur, pch, amp);
}
int readhex(FILE *file, int loc){
     fseek(file, loc, SEEK_SET);
     int val = fgetc(file);
     return val;
}
int readword(FILE *file, int loc){
     int b = readhex(file, loc);
     int a = readhex(file, loc+1);
     if (a == 0){
          return b;
     }else{
          return (a * 0x100) + b;
     }
}
void makestems (char *sco_filename, int numins){
     FILE* m_sco[numins];
     printf("%d\n", numins);
     FILE *sco = fopen(sco_filename, "r");
     int i;
     char m_score_filename[50];
     int p1;
     float p2, p3, p4, p5;

     printf("naming the files\n");
     //create the score files

     for(i = 0; i < numins; i++){
          sprintf(m_score_filename, "%s.%d",sco_filename, i);
          m_sco[i] = fopen(m_score_filename, "w");
          printf("%d", i);
     }
     while(1){
     if(feof(sco)){
          break;
     }
     printf("scan\n");
     fscanf(sco, "i %d %g %g %g %g\n", &p1, &p2, &p3, &p4, &p5);
     printf("write\n");
     fprintf(m_sco[p1-1], "i %d %g %g %g %g\n", p1, p2, p3, p4, p5);
     }

	//create render.py

	char py[50];
	sscanf(sco_filename, "%[^.]", py);
	char score[50];
	strcpy(score, py);
	strcat(score, ".sco.");
	char csd[50];
	strcpy(csd, py);
	strcat(csd, ".csd");

	FILE *pyrender = fopen("render.py", "w");

	fprintf(pyrender, "'''\nBe sure to have #include \"$SCORE\" in your csd file\n'''\nimport os\nsco = \"%s\"\ncsd = \"%s\"\ninstr = %i\nfor i in range(instr): os.system(\"csound --smacro:SCORE=\" + sco + str(i) + \" -o track_\" + str(i) + \".wav \"+ csd)\n", score, csd, numins);	

	fclose(pyrender);

     fclose(sco);
     for(i = 0; i < numins; i++){
     fclose(m_sco[i]);
     }
}

void writepattern(int pattern, float *time, int *patlen, int *patloc, int numchan, 
FILE *file, FILE *sco, float speed, struct NOTE *track, 
int song_count, int songlen, int *prevnote, int *noteoff, int ismulti, long *numlines, int renderscort, FILE *scort){
     int val;
     int ins;
     int testbit; 
	int chan;
     //int chan = -1; //I believe that this value here is causing a glitch on channel 1 for held notes.
	//rewrite this code so that chan initializes with '0' instead of -1
     int i;
     int loc = patloc[pattern] + 9;
     int isnote=0, isins=0, isvol=0, iseffect=0, iseffectdata=0, isvalid = 0, isnewnote;
     int firstval = readhex(file, loc+0);
     printf("\nwhat is the initial value of notedur on chan 1? %d", noteoff[0]);
     for(i = 0; i < patlen[pattern]; i++){
          val = readhex(file,loc + i);
          
          if(isnote){
               isnote = 0;
			printf("this is currently line number %i\n", (int)*numlines);
               if (val == 0x61){
                    noteoff[chan] = 1;
                    printf("\nnote cutoff on channel %d ", chan);
               }else{
				*numlines += 1;
                    noteoff[chan] = 0;
				track[chan].pch=pchconv(val);
				track[chan].time=*time;
				track[chan].dur=speed;
				track[chan].loc=*numlines;
                    printf("\nthe pitch is %g on channel %d ", pchconv(val), chan);
                    if(isvol==0){
                         track[chan].amp = 1;
                         printf("amplitude is 1 ");
                    }
               }
               //not every note is going to have an volume specified. default is 1
          }else if(isins){
               printf("the instrument number is %x ", val);
               isins = 0;
               track[chan].ins = val;
          }else if(isvol){
               printf("amplitude is %x ",val);
               isvol = 0;
               track[chan].amp = (val-0x10)/64.0;
          }else if(iseffect){
               iseffect = 0;
          }else if(iseffectdata){
               iseffectdata = 0;
          }else{
			//idea: if i == 0; chan = 0?
               if(i == 0){
			chan = 0;
			}else if(chan + 1 == numchan){
                   *time += speed;
                   chan = 0;
               }else{
                    chan += 1;
               }
               
               //is it a valid byte of information or did xm2sco mess up?
               isvalid = (val - (val%0x80)) == 0x80;
               //effect data starts out with a 9 instead of an 8
               iseffectdata = (val - (val&0x90)) == 0x90;
              
               if(isvalid){
                    testbit = 0x80;
               }else if(iseffectdata){
                    testbit = 0x90;
               }else{
                    printf("there was an issue in reading pattern %d", pattern);
               }
               //split up the byte
               isnote = ((val - testbit) & 1);
               isins = ((val - testbit) & 2);
               isvol = ((val - testbit) & 4);
               iseffect = ((val - testbit) & 8);
              //noteoff 
               //if(isvalid && i != 0 && val != 0x80 && noteoff[chan] == 0 ){
               if(isvalid && val != 0x80 && noteoff[chan] == 0 ){
                    noteoff[chan] = 1;
                    printf("\n new note on channel %d", chan);
               }
               
               //note off
		if(noteoff[chan]==1 && track[chan].ins != 0 && chan != -1){
                //    printf("\nwriting ch%d i statement..", chan);
               //     track[chan + numchan*2] -= speed;
                    writesco(sco, track[chan].ins, track[chan].time, track[chan].dur, track[chan].pch, track[chan].amp);
				if(renderscort){
					fwrite(&track[chan].loc, sizeof(long), 1, scort);
				}
                    noteoff[chan] = 0;
                    //make instrument number 0, indicating a new instance

                    track[chan].ins = 0;
               }else if(val == 0x80 && noteoff[chan] == 0){
                    track[chan].dur += speed;
               }
          }
     }
     if(song_count == songlen){
          int j;
          float strt;
          for(j = 0; j < numchan; j++){
            if (track[j].ins != 0){
                // printf("\nwriting final i statement to from track %d score...\n", j);
                    //track[j + numchan*2] -= speed;
                 writesco(sco, track[j].ins, track[j].time, track[j].dur, track[j].pch, track[j].amp);
               }
            }
	}
}
