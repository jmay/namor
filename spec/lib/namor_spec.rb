# spec for name component extraction

require "spec_helper"

describe "name extract" do
  it "should handle 2-part names without commas" do
    Namor::extract("john smith").should == ['JOHN', nil, 'SMITH', 'SMITH,JOHN']
  end

  it "should handle 2-part names with commas" do
    Namor::extract("SMITH, JOHN").should == ['JOHN', nil, 'SMITH', 'SMITH,JOHN']
  end

  it "should handle 2-part names with commas and middle initials" do
    Namor::extract("SMITH, JOHN R").should == ['JOHN', 'R', 'SMITH', 'SMITH,JOHN R']
  end

  it "should handle 2-part names with commas and middle initials" do
    Namor::extract("SMITH, JOHN R").should == ['JOHN', 'R', 'SMITH', 'SMITH,JOHN R']
  end

  it "should strip elements within parentheses" do
    Namor::extract("SMITH, JOHN (Jacko) R").should == ['JOHN', 'R', 'SMITH', 'SMITH,JOHN R']
  end

  it "should drop periods" do
    Namor::extract("John R. Smith").should == ['JOHN', 'R', 'SMITH', 'SMITH,JOHN R']
  end

  it "should drop spaces in last name (only when input has a comma)" do
    Namor::extract("Smith Jones, Mary").should == ['MARY', nil, 'SMITHJONES', 'SMITHJONES,MARY']
  end

  it "should drop dashes & apostrophes" do
    Namor::extract("Mary Smith-Jones").should == ['MARY', nil, 'SMITHJONES', 'SMITHJONES,MARY']
    Namor::extract("Mary S. O'Keefe").should == ['MARY', 'S', 'OKEEFE', 'OKEEFE,MARY S']
    Namor::extract("Jean-Michel Claude").should == ['JEANMICHEL', nil, 'CLAUDE', 'CLAUDE,JEANMICHEL']
  end

  it "should concatenate extract name pieces" do
    Namor::extract("rajesh kumar vishnu garuda").should == ['RAJESH', nil, 'KUMARVISHNUGARUDA', 'KUMARVISHNUGARUDA,RAJESH']
    Namor::extract("Kumar, Rajesh Vishnu Garuda").should == ['RAJESH', 'VISHNUGARUDA', 'KUMAR', 'KUMAR,RAJESH VISHNUGARUDA']
  end

  it "should excise suffixes like 'Jr.' from lastnames" do
    Namor::extract("Smith Jr, Edward M").should == ['EDWARD', 'M', 'SMITH', 'SMITH,EDWARD M']
  end

  it "should excise terms from optional suppression list" do
    Namor::extract("Smith Jr, Edward M MD DDS", :suppress => ['MD', 'DDS']).should == ['EDWARD', 'M', 'SMITH', 'SMITH,EDWARD M']
    Namor::extract("Smith Jr, Edward III MD PHD", :suppress => ['MD', 'DDS']).should == ['EDWARD', 'PHD', 'SMITH', 'SMITH,EDWARD PHD']
  end

  it "should handle pathological cases" do
    Namor::extract(", Mary Smith").should == ['MARY', 'SMITH', nil, 'MARY SMITH']
  end
end

describe "with cluster coding" do
  it "should generate cluster labels" do
    Namor::extract_with_cluster("Smith Jr, Edward III MD PHD", :suppress => ['MD', 'DDS']).last.should == 'SMITH_EDWARD_PHD'
  end
end

describe "name componentization" do
  it "should include initials" do
    Namor::components("john q. smith").should == ['JOHN', 'Q', 'SMITH']
  end

  it "should excise common suffixes" do
    Namor::components("john smith III").should == ['JOHN', 'SMITH']
    Namor::components("john smith jr").should == ['JOHN', 'SMITH']
  end

  it "should excise from suppression list" do
    Namor::components("john smith esq.").should == ['ESQ', 'JOHN', 'SMITH']
    Namor::components("john smith esq.", :suppress => ['esq']).should == ['JOHN', 'SMITH']
  end
end
