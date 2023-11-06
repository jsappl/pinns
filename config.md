<!--
Add here global page variables to use throughout your website.
-->
+++
author = "Johannes Sappl"
mintoclevel = 2

prepath = "pinns"

ignore = ["node_modules/"]

generate_rss = false
website_title = "Physics-Informed Neural Networks"
website_description = "Lecture notes on physics-informed neural networks as part of the Continuing Education Programme Data Science at the Universität Innsbruck."
website_url = "https://jsappl.github.io/pinns/"

hasplotly = false
+++

<!--
Add here global latex commands to use throughout your pages.
-->
\newcommand{\R}{\mathbb R}
\newcommand{\N}{\mathbb N}
\newcommand{\scal}[1]{\langle #1 \rangle}
\newcommand{\dd}{\mathrm{d}}
\newcommand{\e}{\mathrm{e}}

\newcommand{\figenv}[3]{
~~~
<figure style="text-align:center;">
<img src="!#2" style="padding:0;width:#3;" alt="#1"/>
<figcaption><b>Figure</b> #1</figcaption>
</figure>
~~~
}
