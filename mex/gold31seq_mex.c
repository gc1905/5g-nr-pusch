/* c = gold31seq_mex(c_init, len)
 *
 * Matlab MEX acceleration for gold31seq function.
 *
 * Copyright 2019 Grzegorz Cisek (grzegorzcisek@gmail.com)
 */


#include "mex.h"
#include <string.h>

void init_x2(unsigned long c_init, char* x2) {
  int i;
  for (i = 0; i < 30; i++) {
    x2[i] = ( ((1 << i) & c_init) != 0 );
  }
}

void gold31seq(unsigned long c_init, size_t len, double* seq_out) {
  const size_t N_c = 1600;
  size_t n;
  char* x1;
  char* x2;
  size_t x_size = N_c + len + 31;
  
  x1 = mxMalloc(x_size);
  memset(x1, 0, x_size);
  x1[0] = 1;

  x2 = mxMalloc(x_size);
  memset(x2, 0, x_size);
  init_x2(c_init, x2);

  for (n = 0; n < len+N_c; n++) {
    x1[31+n] = (x1[n+3] + x1[n]) & 1;
    x2[n+31] = (x2[n+3] + x2[n+2] + x2[n+1] + x2[n]) & 1;
  }

  for (n = 0; n < len; n++) {
    seq_out[n] = (double) ((x1[n+N_c] + x2[n+N_c]) & 1);
  }

  mxFree(x1);
  mxFree(x2);
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
  unsigned long c_init;
  size_t  len;
  double* seq_out;

  /* check for proper number and format of arguments */
  if(nrhs != 2)
    mexErrMsgIdAndTxt("gold31seq:nrhs","Two inputs required.");

  if(nlhs != 1)
    mexErrMsgIdAndTxt("gold31seq:nlhs","One output required.");

  if( !mxIsDouble(prhs[0]) || mxIsComplex(prhs[0]) || !(mxGetM(prhs[0])==1 && mxGetM(prhs[0])==1) )
    mexErrMsgIdAndTxt( "MATLAB:gold31seq:inputNotRealScalarDouble",
      "Input c_init must be a noncomplex scalar.");

  if( !mxIsDouble(prhs[1]) || mxIsComplex(prhs[1]) || !(mxGetM(prhs[1])==1 && mxGetM(prhs[1])==1) )
    mexErrMsgIdAndTxt( "MATLAB:gold31seq:inputNotRealScalarDouble",
      "Input len must be a noncomplex scalar.");

  /* get the input arguments */
  c_init = (unsigned long) mxGetScalar(prhs[0]);
  len = (size_t) mxGetScalar(prhs[1]);

  /* create the output matrix */
  plhs[0] = mxCreateDoubleMatrix(1, (mwSize)len, mxREAL);
  seq_out = mxGetPr(plhs[0]);

  /* call the computational routine */
  gold31seq(c_init, len, seq_out);
}