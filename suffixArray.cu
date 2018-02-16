#include "suffixArray.h"
#include <thrust/host_vector.h>
#include <thrust/device_vector.h>
#include <thrust/sequence.h>
#include <thrust/sort.h>
#include <thrust/scan.h>
#include <thrust/execution_policy.h>
#include <thrust/for_each.h>

#include <iostream>
#include <memory>
#include <stdexcept>

using dstring = thrust::device_vector<char>;
using darray = thrust::device_vector<int>;

__host__
void suffixArray(const darray& s, int n, darray& out, darray& temp, 
            darray& s0, darray& s12, darray& rank, darray& rec_out) {
   // std::cout << "N: " << n << std::endl;
    int n0 = (n + 2) / 3, n1 = (n + 1) / 3, n12 = 2*n / 3;

    thrust::sequence(temp.begin(), temp.begin() + n12);
    thrust::transform(temp.begin(), temp.begin() + n12, temp.begin(), [] __device__ (int x)
    {
        return 3*x/2 + 1;
    });

    {
        const auto data = s.data();
        for (int i=2; i>=0; --i)
        {
            thrust::stable_sort(temp.begin(), temp.begin() + n12, [i, data] __device__ (int a, int b)
            {
                return data[i+a] < data[i+b];
            });
        }
        thrust::copy(temp.begin(), temp.begin() + n12, s12.begin());
    }

    darray rec_in(n12 + 5);
    int cnt = 0;

    {
        darray temp_zero_one(n12 + 5);
        const auto temp_data = temp.data();
        const auto s_data = s.data();
        thrust::sequence(temp_zero_one.begin(), temp_zero_one.begin() + n12);
        thrust::transform(temp_zero_one.begin(), temp_zero_one.begin() + n12, temp_zero_one.begin(), [s_data, temp_data] __device__ (int position)
        {
            if (position == 0)
            {
                return 0;
            }
            for (int i=0; i<3; i++)
            {
                if (s_data[temp_data[position-1] + i] != s_data[temp_data[position] + i])
                {
                    return 1;
                }
            }
            return 0;
        });
        thrust::inclusive_scan(thrust::device, temp_zero_one.begin(), temp_zero_one.begin() + n12, temp_zero_one.begin());
        const auto burek = temp_zero_one.data();
        thrust::sequence(rec_in.begin(), rec_in.end());
        const auto rec_in_data = rec_in.data();
        thrust::for_each(thrust::device, temp_zero_one.begin(), temp_zero_one.begin() + n12, [burek, rec_in_data, temp_data, n1] __device__ (int i)
        {
            rec_in_data[temp_data[i] % 3 == 1 ? temp_data[i] / 3 : temp_data[i]/3 + n1 + 1] = burek[i] + 2; 
        });
        cnt = temp_zero_one[n12-1] + 2;
    }

    // std::cout << "CNT is " << cnt << std::endl; 

    if (cnt != n12 + 1) {
        for (int i=0; i<3; i++)
        {
            rec_in[n12 + i + 1] = 0;
        }
        rec_in[n1] = 1;
        suffixArray(rec_in, n12+1, rec_out, temp, s0, s12, rank, rec_out);
        {
            auto burek = rec_out.data();
            thrust::sequence(s12.begin(), s12.begin() + n12);
            thrust::transform(s12.begin(), s12.begin() + n12, s12.begin(), [burek, n1] __device__ (int i)
            {
                ++i;
                return burek[i]<n1 ? 3*burek[i]+1 : 3*(burek[i]-n1)-1;
            });
        }
    }

    {
        auto burek = s12.data();
        auto nobik = rank.data();
        thrust::sequence(temp.begin(), temp.begin() + n12);
        thrust::for_each(thrust::device, temp.begin(), temp.begin() + n12, [nobik, burek] __device__ (int i)
        {
            nobik[burek[i]] = i+1;
        });
        rank[n] = 0;
    }

    thrust::sequence(s0.begin(), s0.begin() + n0, 0, 3);

    {
        const auto data1 = rank.data();
        thrust::stable_sort(s0.begin(), s0.begin() + n0, [data1] __device__ (int a, int b)
        {
            return data1[a+1] < data1[b+1];
        });
        const auto data2 = s.data();
        thrust::stable_sort(s0.begin(), s0.begin() + n0, [data2] __device__ (int a, int b)
        {
            return data2[a] < data2[b];
        });
    }

    {
        const auto data_s = s.data();
        const auto data_r = rank.data();

        thrust::merge(s12.begin(), s12.begin()+n12, s0.begin(), s0.begin()+n0, out.begin(), [data_s, data_r] __device__ (int u, int v)
        {
            while (true)
            {
                if (data_s[u] != data_s[v]) 
                {
                    return data_s[u] < data_s[v];
                }
                if (u % 3 != 0 && v % 3 != 0)
                {
                    return data_r[u] < data_r[v];
                }
                ++u;
                ++v;
            }
        });
    }

    /*for (int i = 0; i < 2*n/3; i++)
    {
        std::cout << temp[i] << ' ';
    }
    std::cout << std::endl;*/
}

__host__
void suffixArray(const std::string& in, int* out)
{
    const unsigned int n = in.size();
    
    if (n <= 1)
    {
        if (n == 1)
        {
            out[0] = 0;
        }
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