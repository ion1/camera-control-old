#include <linux/ppdev.h>
#include <stdio.h>
#include <sys/ioctl.h>

#define PRINT_CONSTANT(constant) \
  printf ("%-10s = 0x%08x\n", #constant, constant)

int
main (void)
{
  PRINT_CONSTANT (PPRSTATUS);
  PRINT_CONSTANT (PPRCONTROL);
  PRINT_CONSTANT (PPWCONTROL);
  PRINT_CONSTANT (PPRDATA);
  PRINT_CONSTANT (PPWDATA);

  PRINT_CONSTANT (PPCLAIM);
  PRINT_CONSTANT (PPRELEASE);
  PRINT_CONSTANT (PPEXCL);
  PRINT_CONSTANT (PPDATADIR);

  return 0;
}

/* vim:set et sw=2 sts=2: */
