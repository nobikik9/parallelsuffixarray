#include "suffixArray.h"

#include <thrust/adjacent_difference.h>
#include <thrust/device_vector.h>
#include <thrust/for_each.h>
#include <thrust/scan.h>
#include <thrust/sequence.h>
#include <thrust/sort.h>

using dstring = thrust::device_vector<char>;
using darray = thrust::device_vector<int>;

__host__
void suffixArray(const darray& s,
                 int n,
                 darray& out,
                 darray& temp, 
                 darray& s0,
                 darray& s12,
                 darray& rank,
                 darray& rec_out)
{
    const int n0 = (n + 2) / 3;
    const int n1 = (n + 1) / 3;
    const int n12 = 2 * n / 3;

    thrust::transform(thrust::make_counting_iterator(0),
                      thrust::make_counting_iterator(n12),
                      s12.begin(),
                      [] __device__ (int x) { return 3 * x / 2 + 1; });

    {
        const auto data = s.data();
        for (int i = 2; i >= 0; --i)
            thrust::stable_sort(s12.begin(),
                                s12.begin() + n12,
                                [i, data] __device__ (int a, int b) { return data[i + a] < data[i + b]; });
    }

    darray rec_in(n12 + 5);
    int cnt = 0;

    {
        darray temp_zero_one(n12 + 5);
        const auto data_s = s.data();
        thrust::adjacent_difference(s12.begin(),
                                    s12.begin() + n12,
                                    temp_zero_one.begin(),
                                    [data_s] __device__ (int u, int v)
                                    {
                                        for (int i = 0; i < 3; i++)
                                            if (data_s[u + i] != data_s[v + i])
                                                return 1;
                                        return 0;
                                    });
        temp_zero_one[0] = 2;
        thrust::inclusive_scan(temp_zero_one.begin(), temp_zero_one.begin() + n12, temp_zero_one.begin());
        const auto data_t = temp_zero_one.data();
        const auto data_a = s12.data();
        const auto data_r = rec_in.data();
        thrust::for_each(thrust::make_counting_iterator(0),
                         thrust::make_counting_iterator(n12),
                         [data_t, data_a, data_r, n1] __device__ (int i)
                         {
                            if (data_a[i] % 3 == 1)
                                data_r[data_a[i] / 3] = data_t[i];
                            else
                                data_r[data_a[i] / 3 + n1 + 1] = data_t[i];
                         });
        cnt = temp_zero_one[n12-1];
    }

    if (cnt != n12 + 1)
    {
        for (int i = 0; i < 3; i++)
            rec_in[n12 + i + 1] = 0;
        rec_in[n1] = 1;
        suffixArray(rec_in, n12 + 1, rec_out, temp, s0, s12, rank, rec_out);

        {
            auto data_r = rec_out.data();
            thrust::transform(thrust::make_counting_iterator(1),
                              thrust::make_counting_iterator(n12 + 1),
                              s12.begin(),
                              [data_r, n1] __device__ (int i)
                              { return data_r[i] < n1 ? 3 * data_r[i] + 1 : 3 * (data_r[i] - n1) - 1;});
        }
    }

    {
        auto data_s = s12.data();
        auto data_r = rank.data();
        thrust::for_each(thrust::make_counting_iterator(0),
                         thrust::make_counting_iterator(n12),
                         [data_s, data_r] __device__ (int i)
                         { data_r[data_s[i]] = i + 1; });
    }

    rank[n] = 0;
    thrust::sequence(s0.begin(), s0.begin() + n0, 0, 3);

    {
        const auto data_r = rank.data();
        thrust::stable_sort(s0.begin(), s0.begin() + n0, [data_r] __device__ (int a, int b)
        {
            return data_r[a + 1] < data_r[b + 1];
        });
    }

    {
        const auto data_s = s.data();
        thrust::stable_sort(s0.begin(), s0.begin() + n0, [data_s] __device__ (int a, int b)
        {
            return data_s[a] < data_s[b];
        });
    }

    {
        const auto data_s = s.data();
        const auto data_r = rank.data();
        thrust::merge(s12.begin(),
                      s12.begin() + n12,
                      s0.begin(),
                      s0.begin() + n0,
                      out.begin(),
                      [data_s, data_r] __device__ (int u, int v)
                      {
                          while (true)
                          {
                              if (data_s[u] != data_s[v]) 
                                  return data_s[u] < data_s[v];
                              if (u % 3 != 0 && v % 3 != 0)
                                  return data_r[u] < data_r[v];
                              ++u;
                              ++v;
                          }
                      });
    }
}

__host__
void suffixArray(const std::string& in, int* out)
{
    const unsigned int n = in.size();
    
    if (n <= 1)
    {
        if (n == 1)
            out[0] = 0;
        return;
    }

    const unsigned int size = n + 3;

    darray s(in.data(), in.data() + in.size());
    s.resize(size);
    darray temp(size);
    darray s0(size);
    darray s12(size);
    darray rank(size);
    darray rec_out(size);
    darray device_out(n);

    suffixArray(s, n, device_out, temp, s0, s12, rank, rec_out);

    thrust::copy(device_out.begin(), device_out.end(), out);
}
