/* p = crc_calc_mex(b, crc_poly) 
 *
 * Matlab MEX acceleration for nr_38_212_crc_calc function.
 *
 * Copyright 2017 Grzegorz Cisek (grzegorzcisek@gmail.com)
 */

#include "mex.h"

#define CRC_LFSR_LEN_MAX 25

void crc_calc(double* din, size_t din_len, double* poly, size_t poly_len, double* dout) {
  int i, n;
  int lfsr[CRC_LFSR_LEN_MAX] = {0};

  for (i = 0; i < din_len+poly_len-1; i++) {
    /* shift */
    for (n = 0; n < poly_len-1; n++)
      lfsr[n] = lfsr[n+1];
    lfsr[poly_len-1] = (i < din_len) ? (int)din[i] : 0;
    /* add polynomial */
    if (lfsr[0] != 0)
      for (n = 0; n < poly_len; n++)
        lfsr[n] = (lfsr[n] + (int)poly[n]) & 1;
  }

  for (i = 0; i < poly_len-1; i++)
    dout[i] = (double) lfsr[i+1];
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
  double* din;
  size_t din_len;
  double* poly;
  size_t poly_len;
  double* dout;

  /* check for proper number of arguments */
  if(nrhs != 2) {
    mexErrMsgIdAndTxt("crc_calc:nrhs","Two inputs required.");
  }

  if(nlhs != 1) {
    mexErrMsgIdAndTxt("crc_calc:nlhs","One output required.");
  }

  /* get the input arguments */
  din_len = mxGetN(prhs[0]);
  din = mxGetPr(prhs[0]);
  poly_len = mxGetN(prhs[1]);
  poly = mxGetPr(prhs[1]);

  if (poly_len > CRC_LFSR_LEN_MAX) {
    mexErrMsgIdAndTxt("crc_calc:poly_len","Polynomial length is too high. Recompile mex function with sufficient CRC_LFSR_LEN_MAX.");
  }

  /* create the output matrix */
  plhs[0] = mxCreateDoubleMatrix(1, (mwSize)(poly_len-1), mxREAL);
  dout = mxGetPr(plhs[0]);

  /* call the computational routine */
  crc_calc(din, din_len, poly, poly_len, dout);
}
