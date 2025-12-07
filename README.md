# unsloth-rocm 🦥🔥

Unsloth + PyTorch-on-ROCm in a ready-to-use Docker image for AMD GPUs  
(Navi / RDNA2 / RDNA3 – e.g. 7900 XTX).

- Base image: [`rocm/pytorch`](https://hub.docker.com/r/rocm/pytorch) (PyTorch with ROCm backend)   
- Fine-tuning framework: [Unsloth](https://github.com/unslothai/unsloth) (Apache-2.0). 

This repo contains:

- `Dockerfile` – how the image is built
- `docker-compose.build.yml` – a sample compose file for local build + dev use

The idea is to give ROCm users a “batteries-included” Unsloth container and a clean example of how to wire up devices / groups / HF cache.

---

## Requirements

On the host (e.g. Arch, Ubuntu, etc.):

- AMD GPU supported by ROCm / `rocm/pytorch` (MI* or newer Navi, see AMD’s support matrix)   
- ROCm stack installed and working (`rocminfo` sees your GPU)
- Docker or compatible container runtime
- User is in the appropriate groups, e.g.:

```bash
  sudo usermod -aG video,docker $USER
  # log out & back in afterwards
```

You should also see `/dev/kfd` and `/dev/dri` on the host:

```bash
ls /dev/kfd
ls /dev/dri
```

---

## Build locally

Clone the repo (whichever remote you like – GitHub or your local Forgejo):

```bash
git clone https://github.com/zuzupebbles/unsloth-rocm.git
cd unsloth-rocm
```

Build the image:

```bash
# ensure UID/GID match your host user (especially on Arch)
export UID
export GID

docker compose -f docker-compose.build.yml build
```

This will produce a local image named:

```text
zuzupebbles/unsloth-rocm:local
```

You can confirm with:

```bash
docker images | grep unsloth-rocm
```

---

## Run for local dev

Bring up a dev container:

```bash
docker compose -f docker-compose.build.yml up -d
docker compose -f docker-compose.build.yml exec unsloth-rocm bash
```

Inside the container you’ll have:

* user: `unsloth`
* working dir: `/workspace`
* volumes mounted:

    * `./workspace` → `/workspace`
    * `~/.cache/huggingface` → `/data/hf-cache`
    * `./repos-clone` → `/repos-clone`

Quick sanity check in the container:

```bash
python -c "import torch; print(torch.cuda.is_available(), torch.version.cuda, torch.version.hip, torch.version.git_version)"
python -c "import unsloth; print(unsloth.__version__)"
```

(ROCm builds often report HIP instead of CUDA, that’s expected.)
