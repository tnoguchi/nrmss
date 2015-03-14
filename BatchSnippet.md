スタブです。

# Introduction #

```
include ERB::Util
include ActionView::Helpers::NumberHelper
include ActionView::Helpers::TagHelper
include ActionView::Helpers::AssetTagHelper
include ActionView::Helpers::UrlHelper
e = ERB.new(open('app/views/lib/rms/_default.html.erb') { |f| f.read }, nil, "-")

Item.find(:all).each { |item| item.groups.each { |group|
  items = group.items
  e.run(binding)
} }; nil
```