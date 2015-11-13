#include <stdlib.h>
#include <stdio.h>
#include <SFML/System.h>
#include <SFML/Graphics.h>

//extern sfSprite* sfSprite_create();

// print_clock
void print_clock(sfClock* c);

void print_clock(sfClock* c)
{
    printf("clock time: %fll\n", (double)sfClock_getElapsedTime(c).microseconds);
}

void clock_restart(sfClock* c, long long int* time)
{
    *time = sfClock_restart(c).microseconds;
}

int test(float f)
{
    float a;
    float b;
    if(a < b)
        a =0;


}

int rseed = -10;

int clock_test(sfClock* c)
{
    return rseed = (rseed * 1103515245 + 12345) & RAND_MAX;
}

void clock_getElapsedTime(sfClock* c, long long int* time)
{
    *time = sfClock_getElapsedTime(c).microseconds;
}
