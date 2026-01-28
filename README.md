# libp2p Unified Website

The official website for [libp2p](https://libp2p.io) - a modular network stack for peer-to-peer applications.

Built with [Zola](https://www.getzola.org/), a fast static site generator written in Rust.

## Site Structure

| Section | URL Path | Description |
|---------|----------|-------------|
| Home | `/` | Landing page with announcements and events calendar |
| Blog | `/blog/` | News, tutorials, and project updates |
| Guides | `/guides/` | Documentation and learning resources |
| Releases | `/releases/` | Implementation release notes |
| Status | `/status/` | Interoperability test results |
| Get Involved | `/get-involved/` | Community engagement resources |

### Directory Layout

```
unified-website/
├── config.toml              # Site configuration
├── content/                 # Markdown content
│   ├── blog/                # Blog posts
│   ├── guides/              # Documentation
│   │   ├── concepts/        # Core concepts (subsections)
│   │   └── getting-started/ # Getting started guides
│   ├── releases/            # Release notes
│   ├── status/              # Interop status
│   └── get-involved/        # Community pages
├── templates/               # Tera HTML templates
│   ├── shortcodes/          # Reusable content blocks
│   └── components/          # Shared template components
├── sass/                    # SCSS stylesheets
├── static/                  # Static assets (images, fonts, JS)
│   └── img/                 # Images
└── public/                  # Build output (generated)
```

## Adding Content

### Adding a Blog Post

1. Create a new file in `content/blog/` with a descriptive filename:
   ```
   content/blog/my-new-post.md
   ```

2. Add the required front matter at the top of the file:
   ```toml
   +++
   title = "Your Post Title"
   description = "Brief description for SEO and previews"
   date = 2026-01-27
   slug = "url-friendly-slug"

   [taxonomies]
   tags = ["libp2p", "relevant-tag"]

   [extra]
   author = "Your Name"
   header_image = "/img/blog/your-image.png"  # Optional
   +++
   ```

3. Write your content in Markdown below the front matter

4. Add any images to `static/img/blog/`

5. Preview locally with `zola serve`

6. Commit and create a pull request

### Adding a Guide

**For a standalone guide:**

1. Create a file in `content/guides/`:
   ```
   content/guides/my-guide.md
   ```

2. Add front matter:
   ```toml
   +++
   title = "Guide Title"
   description = "What this guide covers"
   weight = 60

   [extra]
   toc = true
   +++
   ```

**For a guide in a subsection (e.g., concepts):**

1. Create a folder in the appropriate section:
   ```
   content/guides/concepts/my-topic/
   ```

2. Add `_index.md` with section front matter:
   ```toml
   +++
   title = "My Topic"
   description = "Section description"
   weight = 10
   +++
   ```

3. Add content pages in the folder as needed

**Ordering:** Use the `weight` field to control sort order (lower values appear first).

### Adding a Release Note

1. Create a file in `content/releases/`:
   ```
   content/releases/go-libp2p-v0.37.0.md
   ```

2. Add the required front matter:
   ```toml
   +++
   title = "go-libp2p v0.37.0"
   description = "Brief summary of the release"
   date = 2026-01-27

   [extra]
   version = "v0.37.0"
   implementation = "go"  # go, rust, js, etc.
   breaking = false
   security = false
   github_release = "https://github.com/libp2p/go-libp2p/releases/tag/v0.37.0"
   +++
   ```

3. Document highlights, new features, bug fixes, and breaking changes

## Shortcodes

Use these shortcodes in your Markdown content:

### YouTube Video

```markdown
{{ youtube(id="VIDEO_ID") }}

{{ youtube(id="VIDEO_ID", title="Video Title", start=120) }}
```

### Alert/Callout

```markdown
{% alert(type="note") %}
Your content here with **markdown** support.
{% end %}

{% alert(type="tip", title="Pro Tip") %}
Custom title with a specific type.
{% end %}
```

Available types: `note`, `tip`, `warning`, `danger`, `info`

### Mermaid Diagrams

```markdown
{% mermaid() %}
graph TD
    A[Start] --> B[End]
{% end %}
```

### Collapsible Details

```markdown
{% details(summary="Click to expand") %}
Hidden content here.
{% end %}
```

## Events & Calendar

The libp2p community calendar is available at [lu.ma/libp2p](https://lu.ma/libp2p).

### Proposing an Event

To get an event listed on the calendar:

1. **Contact the community** through one of these channels:
   - Discord: [Community Channel](https://discord.gg/ehaey3C733)
   - Slack: [#libp2p-community](https://filecoinproject.slack.com/archives/C06HV0D00E5)
   - GitHub: Open an issue in the [website repository](https://github.com/libp2p/website)

2. **Include event details:**
   - Event name
   - Date and time (with timezone)
   - Description
   - Registration link (if applicable)

3. **Relevance:** Events should be related to libp2p or the broader peer-to-peer/web3 ecosystem

The libp2p team will review and add approved events to the calendar.

## Local Development

### Prerequisites

- [Zola](https://www.getzola.org/documentation/getting-started/installation/) v0.17 or later

### Development Server

Start a local server with live reload:

```bash
zola serve
```

The site will be available at http://127.0.0.1:1111. Changes to content and templates automatically trigger a rebuild.

### Building for Production

Generate the static site:

```bash
zola build
```

Output is written to the `public/` directory.

### Link Checking

Verify internal links are valid:

```bash
zola check
```

## Configuration

Site configuration is in `config.toml`. Key settings:

- `base_url` - Production URL (https://libp2p.io)
- `[extra]` - Custom variables for templates
- `[[extra.nav]]` - Navigation menu items
- `[[taxonomies]]` - Tag and author taxonomies

### Community Links

The following community links are configured in `config.toml`:

| Platform | Community | Implementers |
|----------|-----------|--------------|
| Discord | [Community](https://discord.gg/ehaey3C733) | [Implementers](https://discord.gg/Ae4TbahHaT) |
| Slack | [Community](https://filecoinproject.slack.com/archives/C06HV0D00E5) | [Implementers](https://filecoinproject.slack.com/archives/C03K82MU486) |
| Matrix | [Community](https://matrix.to/#/#libp2p-community:matrix.org) | [Implementers](https://matrix.to/#/#libp2p-implementers:ipfs.io) |

## Related Resources

- **Live Site:** https://libp2p.io
- **Specifications:** https://specs.libp2p.io
- **Discussion Forum:** https://discuss.libp2p.io
- **GitHub Organization:** https://github.com/libp2p

### Implementation Repositories

- [go-libp2p](https://github.com/libp2p/go-libp2p)
- [rust-libp2p](https://github.com/libp2p/rust-libp2p)
- [js-libp2p](https://github.com/libp2p/js-libp2p)

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test locally with `zola serve`
5. Submit a pull request

For security issues, contact security@libp2p.io.
