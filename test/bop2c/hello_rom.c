/* Program generated by bop2c */
/* Original circuit : hello_rom.bop , Main = "Main" */

#include <stdlib.h>
#include <stdio.h>

/* Reads a line of text from standard input into a buffer of given size.
   Returns 0 on success, and exit 1 on error. */
int readLineFromStdin(char* buffer, size_t bufferSize) {
  /* Read a line of text from standard input into the buffer. */
  size_t i = 0;
  int c = getchar();
  while (i < bufferSize-1 && c != '\n' && c != EOF) {
    buffer[i] = (char)c;
    i++;
    c = getchar();
  }
  buffer[i] = '\0';

  if (i == 0 && c == EOF) {
    exit(0);
  }

  if (i < bufferSize-1) {
    fprintf(stderr, "Input line too short.\n");
    fprintf(stderr, "Expected %zu bits - got %zu.\n", bufferSize-1, i);
    fflush(stderr);
    exit(1);
  }

  /* Check that the line ends with a newline character */
  if (i == bufferSize-1 && c != '\n' && c != EOF) {
    fprintf(stderr, "Input line too long.\n");
    fprintf(stderr, "Expected %zu bits followed by '\\n'.\n", bufferSize-1);
    exit(1);
  }

  return 0;
}

unsigned char rom0[4][4] = {
  {0, 0, 0, 1}, {0, 0, 1, 0}, {0, 1, 0, 0}, {1, 0, 0, 0}};

void call_rom0(unsigned char e0, unsigned char e1, unsigned char *s0,
               unsigned char *s1, unsigned char *s2, unsigned char *s3) {
  int index = e0 + 2 * e1;
  *s0 = rom0[index][0];
  *s1 = rom0[index][1];
  *s2 = rom0[index][2];
  *s3 = rom0[index][3];
}

unsigned char input_string[3];

void input(unsigned char *e0, unsigned char *e1) {
  readLineFromStdin(input_string, 3);
  *e0 = (input_string[0] == '1');
  *e1 = (input_string[1] == '1');
}

char output_string[5] = "0000";

void output(unsigned char e0, unsigned char e1, unsigned char e2,
            unsigned char e3) {
  output_string[0] = e0 ? '1' : '0';
  output_string[1] = e1 ? '1' : '0';
  output_string[2] = e2 ? '1' : '0';
  output_string[3] = e3 ? '1' : '0';
  fprintf(stdout, "%s\n", output_string);
  fflush(stdout);
}

unsigned char s_0_0, s_0_1, s_1_0, s_1_1, s_1_2, s_1_3;

int main(int argc, char **argv) {
  int ncy = 1, index_cy = 0, r = 0;
  if (argc > 1) r = sscanf(argv[1], "%d", &ncy);
  while (index_cy < ncy) {
    if (r) index_cy++;
    input(&s_0_0, &s_0_1);
    call_rom0(s_0_0, s_0_1, &s_1_0, &s_1_1, &s_1_2, &s_1_3);
    output(s_1_0, s_1_1, s_1_2, s_1_3);
  }
  return(0);
}
