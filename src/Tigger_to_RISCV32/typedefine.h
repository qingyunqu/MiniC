#ifndef __TYPEDEFINE_H_
#define __TYPEDEFINE_H_

#define __DEBUG_
#ifdef __DEBUG_
#define dprintf(format,...) fprintf(stderr,format,##__VA_ARGS__)
#else
#define dprintf(format,...)
#endif

#define riscprintf(format,...) fprintf(yyout,format,##__VA_ARGS__)

#endif
