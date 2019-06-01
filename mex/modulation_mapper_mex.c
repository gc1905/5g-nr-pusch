/* iq = modulation_mapper_mex(x, Q_m, mod_tbl)
 *
 * Matlab MEX acceleration for modulation_mapper function.
 *
 * Copyright 2019 Grzegorz Cisek (grzegorzcisek@gmail.com)
 */

#include "mex.h"

void modulation_mapper(double* bitstream, size_t bitstream_size, int ord, double* A_re, double* A_im, double* iq_re, double* iq_im) {
  int i, j, t;

  for (i = 0; i < bitstream_size / ord; i++) {
    t = 0;
    for (j = 0; j < ord; j++) {
      t += bitstream[i * ord + j] * (1 << (ord - j - 1));
    }
    iq_re[i] = A_re[t];
    iq_im[i] = A_im[t];
  }
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
  double* bitstream;
  size_t bitstream_size;

  int ord;

  double* A_re;
  double* A_im;

  size_t iq_size;
  double* iq_re;
  double* iq_im;

  /* check for proper number of arguments */
  if(nrhs != 3) {
    mexErrMsgIdAndTxt("modulation_demapper_soft:nrhs","Three inputs required.");
  }

  if(nlhs > 1) {
    mexErrMsgIdAndTxt("modulation_demapper_soft:nlhs","At most one output required.");
  }

  /* get the input arguments */
  bitstream_size = mxGetM(prhs[0]) * mxGetN(prhs[0]);
  bitstream = mxGetPr(prhs[0]);

  ord = (int) mxGetScalar(prhs[1]);

  A_re = mxGetPr(prhs[2]);
  A_im = mxGetPi(prhs[2]);

  /* create the output matrix */
  iq_size = bitstream_size / ord;
  plhs[0] = mxCreateDoubleMatrix((mwSize)iq_size, 1, mxCOMPLEX);

  /* get a pointer to the real data in the output matrix */
  iq_re = mxGetPr(plhs[0]);
  iq_im = mxGetPi(plhs[0]);

  /* call the computational routine */
  modulation_mapper(bitstream, bitstream_size, ord, A_re, A_im, iq_re, iq_im);
}