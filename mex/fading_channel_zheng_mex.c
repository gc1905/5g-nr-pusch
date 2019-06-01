/* c = fading_channel_zheng_mex(f_d, f_s, ns, N_sin)
 *
 * Matlab MEX acceleration for fading_channel_zheng function.
 *
 * Copyright 2017 Grzegorz Cisek (grzegorzcisek@gmail.com)
 */

#define _USE_MATH_DEFINES
#include <math.h>
#include <time.h>
#include "mex.h"

#define N_SIN_MAX 32
#define RAND() ((double)(rand()))/((double)(RAND_MAX))

void fading_channel_zheng(double f_doppler, double f_sampling, double* n_s, size_t n_s_len, int N_sin, double* out_re, double* out_im) {
  int i, j;
  double th;
  double pr[N_SIN_MAX];
  double pi[N_SIN_MAX];
  double argr[N_SIN_MAX];
  double argi[N_SIN_MAX];  
  double s, two_pi_fd, t;

  s = sqrt(2.0 / (double)N_sin);
  two_pi_fd = 2 * M_PI * f_doppler;

  th = 2 * M_PI * (RAND() - 0.5);
  for (i = 0; i < N_sin; i++) {
    pr[i] = 2 * M_PI * (RAND() - 0.5);
    pi[i] = 2 * M_PI * (RAND() - 0.5);
    argr[i] = two_pi_fd * cos((M_PI * (2.0*(i+1) - 1) + th) / (double)(4 * N_sin));
    argi[i] = two_pi_fd * sin((M_PI * (2.0*(i+1) - 1) + th) / (double)(4 * N_sin));
  }
 
  for (i = 0; i < n_s_len; i++) {
    t = n_s[i] / f_sampling;
    out_re[i] = 0.0;
    out_im[i] = 0.0;
    for (j = 0; j < N_sin; j++) {
      out_re[i] += cos(t * argr[j] + pr[j]);
      out_im[i] += cos(t * argi[j] + pi[j]);
    }
    out_re[i] *= s;
    out_im[i] *= s;
  }
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
  double f_doppler;
  double f_sampling;
  double *n_s;                 /* Nx1 vector of time indices*/
  int N_sin;                /* number of sinusoids */
  double *out_re;              /* Nx1 output matrix real part*/
  double *out_im;              /* Nx1 output matrix imaginary part */
  size_t n_s_len;

  /* check for proper number of arguments */
  if(nrhs == 3) {
    N_sin = 8;
  } else if(nrhs != 4) {
    mexErrMsgIdAndTxt("fading_channel_zheng:nrhs","Four inputs required.");
  } else {
    N_sin = mxGetScalar(prhs[3]);
  }

  if(nlhs!=1) {
    mexErrMsgIdAndTxt("fading_channel_zheng:nlhs","One output required.");
  }

  if (N_sin > N_SIN_MAX) {
    mexErrMsgIdAndTxt("fading_channel_zheng:N_sin","N_sin is too high. Recompile mex function with sufficient N_SIN_MAX.");
  }

  /* get the input arguments */
  f_doppler  = mxGetScalar(prhs[0]);
  f_sampling = mxGetScalar(prhs[1]);
  n_s = mxGetPr(prhs[2]);
  n_s_len = mxGetN(prhs[2]);

  /* create the output matrix */
  plhs[0] = mxCreateDoubleMatrix((mwSize)n_s_len, 1, mxCOMPLEX);

  /* get a pointer to the real data in the output matrix */
  out_re = mxGetPr(plhs[0]);
  out_im = mxGetPi(plhs[0]);

  /* call the computational routine */
  fading_channel_zheng(f_doppler, f_sampling, n_s, n_s_len, N_sin, out_re, out_im);
}
