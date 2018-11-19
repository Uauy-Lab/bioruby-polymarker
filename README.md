# PolyMarker

This is a server to facilitate the use of PolyMarker.



# System dependencies

This server is developed with ```ruby 2.4``` on ```rails 5.1```. Other versions may work, but it is not tested. PolyMarker is tested in MacOS X and Linux (Ubuntu). PolyMarker is queued using ```sidekiq``` which also depends in ```redis```. 

You need to have installed ```ncbi-blast```.


# Setting up the server.




The first thing to do is to load the different references


```bash
rake reference:add[references.yml]
```

The file is formated as ```yaml```. It can contain several references with the following fields:

 * **name**. The name that is going to be displayed in the server
 * **path**. The full path to the uncompressed fasta file with the reference. The fai and blast indeces will be generated on that path.
 * **genome_count**. The number of genomes in the reference: 1 for tetraplods, 2 for tetraploids, etc.
 * **arm_description** The algorithm used in polymarker to parse  


```yaml
-reference:
  name : RefSeq v1.0
  path: /home/USER/References/161010_Chinese_Spring_v1.0_pseudomolecules.fasta
  genome_count: 3
  arm_selection: nrgene
  description: >
    Reference sequence available in [website](http://tada/)
    The reference contains the chromosomes assembled as pseudomolecules,
    hence it is possible to distinguish duplications in the same chromosome.
```

## Important Note
On some machines due to version differences (either ruby/rails/os etc.), webpacker/webpack can malfunction and an error could occur such as:
* the following error
```
[Webpacker] Compilation failed:
  /usr/lib/ruby/vendor_ruby/bundler/rubygems_integration.rb:458:in `block in replace_bin_path': can't find executable webpack for gem webpacker (Gem::Exception)
	from /usr/lib/ruby/vendor_ruby/bundler/rubygems_integration.rb:489:in `block in replace_bin_path
```
In this case do the following:
* `gem install webpacker`
    * yes to all except:
      * **app/javascript/packs/application.js**
      * **config/webpack/environment.js**
    * Modify **config/webpack/environment.js**
      * `environment.plugins.provide` --> `environment.plugins.prepend`
      * `module.exports = environment.toWebpackConfig()` --> `module.exports = environment`