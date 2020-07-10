# Block Place

- Have `cargo` and `zig` installed

```
# Build default-plugin
zig build

# Link the plugin folder so that block-place-server will see it
ln -s zig-cache/bin/plugins ./ 

# Run the server
cargo run -p block-place-server

# In a different terminal...
cargo run -p block-place-client
```
