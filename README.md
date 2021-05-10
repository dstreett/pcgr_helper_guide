# How to run PCGR in docker

# Create volume with required PCGR download

Unfortunately, we cannot push/pull volumes up to docker-hub
and the first step is to recreate the volume I have locally.

We could do this all within docker, but that would make one of the docker
layers very large, so it seemed best to take a slightly more manual path.


``` bash
docker volume create pcgr_data
docker run -it -v pcgr_data:/data --rm alpine:3.7 sh
# in docker now
apk get axel # this will allow us to download with multiple connections
# you might want to change number of connects based on cores and internet quality
mkdir /data
cd /data
axel -n 5 http://insilico.hpc.uio.no/pcgr/pcgr.databundle.grch37.20201123.tgz
gzip -dc pcgr.databundle.grch37.20201123.tgz | tar xvf -
```

Great, we now have the volume properly setup.

# Create image to run PCGR in


This is going to take a big, under the hood, PCGR either uses docker or conda.
Since we are already in docker, we are using the conda approach and it takes
a bit to download.

First, we have to build the image

``` bash
docker build -f pcgr.dockerfile -t pcgr_workflow .
```

Now, we create a container from that container.


``` bash
docker run -it -v pcgr_data:/data --rm pcgr_workflow bash
```

Lastly, we can run the example data through PCGR.

``` bash
# Within docker from the previous command.
pcgr.py --pcgr_dir /data --output_dir ./test_out --sample_id tumor_sample.BRCA --genome_assembly grch37 --conf examples/example_BRCA.toml --input_vcf examples/tumor_sample.BRCA.vcf.gz --tumor_site 9 --input_cna examples/tumor_sample.BRCA.cna.tsv --tumor_purity 0.9 --tumor_ploidy 2.0 --include_trials --assay WES --estimate_signatures --estimate_msi_status --estimate_tmb --no_vcf_validate --no-docker
```
