#include <TMB.hpp>
#include <Eigen/Sparse>
#include <vector>
using namespace density;
using Eigen::SparseMatrix;


template<class Type>
SparseMatrix<Type> iid_Q(int N){
SparseMatrix<Type> Q(N, N);
for(int i = 0; i < N; i++){
    Q.insert(i,i) = 1.;
}
return Q;
}

template<class Type>
SparseMatrix<Type> lcar_Q(SparseMatrix<Type> Wstar, Type rho, Type sigma){
    int N = Wstar.rows();

    SparseMatrix<Type> I(N, N);
    for(int i = 0; i < N; i++){
        I.insert(i,i) = 1.;
    }

    SparseMatrix<Type> Q = (1. / sigma) * (rho * (Wstar) + (1. - rho) * I);
    return Q;
}

template<class Type>
SparseMatrix<Type> ar_Q(int N, Type rho, Type sigma) {
    SparseMatrix<Type> Q(N,N);
    Q.insert(0,0) = (1.) / pow(sigma, 2.);
    for (size_t n = 1; n < N; n++) {
        Q.insert(n,n) = (1. + pow(rho, 2.)) / pow(sigma, 2.);
        Q.insert(n-1,n) = (-1. * rho) / pow(sigma, 2.);
        Q.insert(n,n-1) = (-1. * rho) / pow(sigma, 2.);
    }
    Q.coeffRef(N-1,N-1) = (1.) / pow(sigma, 2.);
    return Q;
}

template<class Type>
Type objective_function<Type>::operator() (){

    DATA_ARRAY(yobs);
    DATA_SPARSE_MATRIX(Wstar); // pre compiled wstar matrix
    DATA_INTEGER(option);
    printf("%s\n", "Data loaded");

    PARAMETER_ARRAY(phi);
    PARAMETER_VECTOR(log_sigma);
    PARAMETER_VECTOR(logit_rho);
    PARAMETER(beta);
    PARAMETER(log_sig_eps);
    printf("%s\n", "Parameters set.");

    printf("%s\n", "Transform parameters.");
    Type sig_eps = exp(log_sig_eps);
    vector<Type> sigma = exp(log_sigma);
    vector<Type> rho = Type(1.) / (Type(1.) + exp(Type(-1.) * logit_rho));


    int L = yobs.dim(0);        // number of locations
    int A = yobs.dim(1);        // number of ages
    int T = yobs.dim(2);        // number of years

    // Initiate log likelihood
    Type nll = 0.;

    // Probability of random effects
    printf("%s\n", "Build precision matrix.");
    SparseMatrix<Type> Q_loc = lcar_Q(Wstar, rho[0], sigma[0]);
    SparseMatrix<Type> Q_age = ar_Q(A, rho[1], sigma[1]);
    SparseMatrix<Type> Q_time = ar_Q(T, rho[2], sigma[2]);

    printf("%s\n", "Eval RE likelihood.");
    if(option > 0){
        nll += SEPARABLE(GMRF(Q_time), SEPARABLE(GMRF(Q_age), GMRF(Q_loc)))(phi);
    }

    printf("%s\n", "Make estimates.");
    // Make predictions
    array<Type> yhat(L, A, T);
    for (int l = 0; l < L; l++) {
        for (int a = 0; a < A; a++) {
            for (int t = 0; t < T; t++) {
                yhat(l,a,t) = beta + phi(l,a,t);
            }
        }
    }

    printf("%s\n", "Data likelihood.");
    // Probability of params
    for (int l = 0; l < L; l++) {
        for (int a = 0; a < A; a++) {
            for (int t = 0; t < T; t++) {
                nll -= dnorm(yobs(l,a,t), yhat(l,a,t), sig_eps, true);
            }
        }
    }

    printf("%s\n", "Report values.");
    REPORT(sigma);
    REPORT(rho);
    REPORT(sig_eps);
    REPORT(beta);
    REPORT(yhat);
    REPORT(Q_loc);

    return nll;
}
