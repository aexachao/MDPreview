marked.use({
    renderer: {
        heading(text, level, raw) {
            // text may contain HTML from inline markdown processing, so strip HTML tags too
            var cleanText = text
                .replace(/<[^>]+>/g, '')  // remove HTML tags
                .replace(/&amp;/g, '&')
                .replace(/&lt;/g, '<')
                .replace(/&gt;/g, '>')
                .replace(/&quot;/g, '"')
                .replace(/&#39;/g, "'");
            // Only replace spaces with hyphens, keep all other characters including Chinese
            var anchor = cleanText.toLowerCase().replace(/ /g, '-');
            return '<h' + level + ' id="' + anchor + '">' + text + '</h' + level + '>';
        }
    }
});