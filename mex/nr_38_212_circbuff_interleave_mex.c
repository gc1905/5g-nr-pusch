/* f = nr_38_212_circbuff_interleave_mex(d, E, Q_m, k_0)
 *
 * Matlab MEX acceleration for nr_38_212_rate_matching_ldpc function.
 *
 * Copyright 2019 Grzegorz Cisek (grzegorzcisek@gmail.com)
 */

#include <stdlib.h>
#include "mex.h"

void circbuff_interleave(double* bits_d, size_t bits_d_len, double* bits_f, size_t bits_f_len, int Q_m, int k_0) {
  double* bits_e;
  int i, j, EdQm;

  bits_e = mxMalloc(bits_f_len * sizeof(double));

  i = k_0;
  j = 0;

  while (j < bits_f_len) {
    if (bits_d[i] != -1.0) {
      bits_e[j] = bits_d[i];
      j++;
    }

    if (i >= bits_d_len - 1) {
      i = 0;
    } else {
      i++;
    }
  }

  EdQm = (int) (bits_f_len / Q_m);

  for (i = 0; i < EdQm; i++)
    for (j = 0; j < Q_m; j++)
      bits_f[j+i*Q_m] = bits_e[j*EdQm+i];

  mxFree(bits_e);
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
  double* bits_d;
  size_t bits_d_len;
  double* bits_f;
  size_t bits_f_len;
  int Q_m, k_0;

  /* check for proper number of arguments */
  if(nrhs != 4) {
    mexErrMsgIdAndTxt("nr_38_212_circbuff_interleave:nrhs","Four inputs required.");
  }

  if(nlhs != 1) {
    mexErrMsgIdAndTxt("nr_38_212_circbuff_interleave:nlhs","One output required.");
  }

  /* get the input arguments */
  bits_d_len = mxGetN(prhs[0]) * mxGetM(prhs[0]);
  bits_d = mxGetPr(prhs[0]);
  bits_f_len = (int) mxGetScalar(prhs[1]);
  Q_m = (int) mxGetScalar(prhs[2]);
  k_0 = (int) mxGetScalar(prhs[3]);

  /* create the output matrix */
  plhs[0] = mxCreateDoubleMatrix(1, (mwSize)bits_f_len, mxREAL);

  /* get a pointer to the real data in the output matrix */
  bits_f = mxGetPr(plhs[0]);

  /* call the computational routine */
  circbuff_interleave(bits_d, bits_d_len, bits_f, bits_f_len, Q_m, k_0);
}
