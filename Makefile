install:
	gem install bundler jekyll

run:
	bundle exec jekyll serve --baseurl ''

publish:
	bundle exec jekyll build
