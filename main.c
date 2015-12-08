#include <stdlib.h>

#include <time.h>

#include <stdio.h>

#include <SFML/System.h>
#include <SFML/Graphics.h>
#include <SFML/Window.h>

int main(int argc,char **argv)
{
//    sfClock* c = sfClock_create();
//    sfClock_restart(c);
//
//    srand(time(NULL));
//    printf("%i", rand());

    printf("%i\n", sizeof(sfRenderStates));
    printf("%i\n", 9*4 + 4 + 4 + 4);

    printf("%i", (int)sfKeyLShift);

    return EXIT_SUCCESS;
}
