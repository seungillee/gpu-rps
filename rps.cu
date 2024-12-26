#include <cuda_runtime.h>
#include <curand_kernel.h>
#include <iostream>
#include <vector>

#define N 10 // Number of rounds

__global__ void randomChoiceKernel(int *choices, unsigned long seed)
{
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx < N)
    {
        curandState state;
        curand_init(seed, idx, 0, &state);
        choices[idx] = curand(&state) % 3; // Generate random 0, 1, or 2
    }
}

void determineWinner(const std::vector<int> &gpu1, const std::vector<int> &gpu2)
{
    for (int i = 0; i < N; ++i)
    {
        std::string winner;
        if (gpu1[i] == gpu2[i])
        {
            winner = "Tie";
        }
        else if ((gpu1[i] == 0 && gpu2[i] == 2) ||
                 (gpu1[i] == 1 && gpu2[i] == 0) ||
                 (gpu1[i] == 2 && gpu2[i] == 1))
        {
            winner = "GPU 1 Wins";
        }
        else
        {
            winner = "GPU 2 Wins";
        }
        std::cout << "Round " << i + 1 << ": GPU 1 -> " << gpu1[i]
                  << ", GPU 2 -> " << gpu2[i] << " | " << winner << "\n";
    }
}

int main()
{
    int *d_gpu1, *d_gpu2;
    int h_gpu1[N], h_gpu2[N];

    cudaMalloc(&d_gpu1, N * sizeof(int));
    cudaMalloc(&d_gpu2, N * sizeof(int));

    randomChoiceKernel<<<1, N>>>(d_gpu1, time(0));     // GPU 1
    randomChoiceKernel<<<1, N>>>(d_gpu2, time(0) + 1); // GPU 2

    cudaMemcpy(h_gpu1, d_gpu1, N * sizeof(int), cudaMemcpyDeviceToHost);
    cudaMemcpy(h_gpu2, d_gpu2, N * sizeof(int), cudaMemcpyDeviceToHost);

    cudaFree(d_gpu1);
    cudaFree(d_gpu2);

    std::vector<int> gpu1(h_gpu1, h_gpu1 + N);
    std::vector<int> gpu2(h_gpu2, h_gpu2 + N);

    determineWinner(gpu1, gpu2);

    return 0;
}