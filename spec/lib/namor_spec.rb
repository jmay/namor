# spec for name component extraction

require "spec_helper"

describe "name extract" do
  before(:all) do
    @namor = Namor::Namor.new
    @namor.config(:suppress => ['MD', 'dds', 'M\.D'])
  end

  it "should handle 2-part names without commas" do
    @namor.extract("john smith").should == ['JOHN', nil, 'SMITH', 'SMITH,JOHN', 'SMITH,JOHN']
  end

  it "should handle 2-part names with commas" do
    @namor.extract("SMITH, JOHN").should == ['JOHN', nil, 'SMITH', 'SMITH,JOHN', 'SMITH,JOHN']
  end

  it "should handle 2-part names with commas and middle initials" do
    @namor.extract("SMITH, JOHN R").should == ['JOHN', 'R', 'SMITH', 'SMITH,JOHN R', 'SMITH,JOHN R']
  end

  it "should handle 2-part names with commas and middle initials" do
    @namor.extract("SMITH, JOHN R").should == ['JOHN', 'R', 'SMITH', 'SMITH,JOHN R', 'SMITH,JOHN R']
  end

  it "should strip elements within parentheses" do
    @namor.extract("SMITH, JOHN (Jacko) R").should == ['JOHN', 'R', 'SMITH', 'SMITH,JOHN R', 'SMITH,JOHN R']
  end

  it "should drop periods" do
    @namor.extract("John R. Smith").should == ['JOHN', 'R', 'SMITH', 'SMITH,JOHN R', 'SMITH,JOHN R']
  end

  it "should drop spaces in last name (only when input has a comma)" do
    @namor.extract("Smith Jones, Mary").should == ['MARY', nil, 'SMITHJONES', 'SMITHJONES,MARY', 'JONES,MARY']
  end

  it "should drop dashes, apostrophes, ampersands" do
    @namor.extract("Mary Smith-Jones").should == ['MARY', nil, 'SMITHJONES', 'SMITHJONES,MARY', 'JONES,MARY']
    @namor.extract("Mary S. O'Keefe").should == ['MARY', 'S', 'OKEEFE', 'OKEEFE,MARY S', 'OKEEFE,MARY S']
    @namor.extract("Jean-Michel Claude").should == ['JEANMICHEL', nil, 'CLAUDE', 'CLAUDE,JEANMICHEL', 'CLAUDE,JEANMICHEL']
    @namor.extract("Smith, Bob & Sue").should == ['BOB', 'SUE', 'SMITH', 'SMITH,BOB SUE', 'SMITH,BOB SUE']
    @namor.extract("Research & Development").should == ['RESEARCH', nil, 'DEVELOPMENT', 'DEVELOPMENT,RESEARCH', 'DEVELOPMENT,RESEARCH']
  end

  it "should concatenate extract name pieces" do
    @namor.extract("rajesh kumar vishnu garuda").should == ['RAJESH', nil, 'KUMARVISHNUGARUDA', 'KUMARVISHNUGARUDA,RAJESH', 'GARUDA,RAJESH']
    @namor.extract("Kumar, Rajesh Vishnu Garuda").should == ['RAJESH', 'VISHNUGARUDA', 'KUMAR', 'KUMAR,RAJESH VISHNUGARUDA', 'KUMAR,RAJESH VISHNUGARUDA']
  end

  it "should excise suffixes like 'Jr.' from lastnames" do
    @namor.extract("Smith Jr, Edward M").should == ['EDWARD', 'M', 'SMITH', 'SMITH,EDWARD M', 'SMITH,EDWARD M']
  end

  it "should excise terms from optional suppression list" do
    @namor.extract("Smith Jr, Edward M MD DDS").should == ['EDWARD', 'M', 'SMITH', 'SMITH,EDWARD M', 'SMITH,EDWARD M']
    @namor.extract("Smith Jr, Edward M M.D.").should == ['EDWARD', 'M', 'SMITH', 'SMITH,EDWARD M', 'SMITH,EDWARD M']
    @namor.extract("Smith Jr, Edward III MD PHD").should == ['EDWARD', 'PHD', 'SMITH', 'SMITH,EDWARD PHD', 'SMITH,EDWARD PHD']
  end

  it "should handle pathological cases" do
    @namor.extract(", Mary Smith").should == ['MARY', 'SMITH', nil, 'MARY SMITH', 'MARY SMITH']
  end

  it "should squash multi-part last names" do
    @namor.extract("Al Hassan, Bashar").should == ['BASHAR', nil, 'ALHASSAN', 'ALHASSAN,BASHAR', 'HASSAN,BASHAR']
    @namor.extract("Bashar Al-Hassan").should == ['BASHAR', nil, 'ALHASSAN', 'ALHASSAN,BASHAR', 'HASSAN,BASHAR']
  end

  it "should squash hyphenated first names" do
    @namor.extract("Smith,Anne-Marie").should == ['ANNEMARIE', nil, 'SMITH', 'SMITH,ANNEMARIE', 'SMITH,ANNEMARIE']
  end

  it "should treat some cases with periods as first.last" do
    @namor.extract("john.smith").should == ['JOHN', nil, 'SMITH', 'SMITH,JOHN', 'SMITH,JOHN']
  end

  it "should generate estimated maiden names" do
    @namor.extract("Jones-De Quento, Maria").should == ['MARIA', nil, 'JONESDEQUENTO', 'JONESDEQUENTO,MARIA', 'DEQUENTO,MARIA']
    @namor.extract_with_cluster("Jones-De Quento, Maria").should == ['MARIA', nil, 'JONESDEQUENTO', 'JONESDEQUENTO,MARIA', 'DEQUENTO,MARIA', 'JONESDEQUENTO_MARIA']
  end
end

describe "with cluster coding" do
  before(:all) do
    @namor = Namor::Namor.new
    @namor.config(:suppress => ['MD', 'DDS'])
  end

  it "should generate cluster labels" do
    @namor.extract_with_cluster("Smith Jr, Edward III MD PHD").last.should == 'SMITH_EDWARD_PHD'
  end
end

describe "name componentization" do
  before(:all) do
    @namor = Namor::Namor.new
    @namor.config(:suppress => ['esq'])
  end

  it "should include initials" do
    @namor.components("john q. smith").should == ['JOHN', 'Q', 'SMITH']
  end

  it "should excise common suffixes" do
    @namor.components("john smith III").should == ['JOHN', 'SMITH']
    @namor.components("john smith jr").should == ['JOHN', 'SMITH']
  end

  it "should excise from suppression list" do
    @namor.components("john smith esk.").should == ['ESK', 'JOHN', 'SMITH']
    @namor.components("john smith esq.").should == ['JOHN', 'SMITH']
  end

  it "should scrub individual name components of punctuation and titles" do
    @namor.fullscrub('Foxworthy-Smythe, ESQ.').should == 'FOXWORTHYSMYTHE'
  end

  it "should delete strings inside parens" do
    @namor.scrub("O'Hara (Morrison)").should == 'OHARA'
    @namor.scrub("  Smith  (Brown) ").should == 'SMITH'
  end

  it "should deal with periods in names" do
    @namor.scrub("G. Gordon").should == 'G GORDON'
  end

  it "should remove junk prefixing" do
    @namor.scrub("ZZJOHN SMITH").should == 'JOHN SMITH'
  end

  it "should allow case-specific word suppression" do
    @namor.scrub("Amazing Magician", :suppress => ['magician', nil, 'conjuror']).should == 'AMAZING'
    @namor.scrub("Jones, Susan Select Transcriptionist", :suppress => ['transcriptionist']).should == 'JONES, SUSAN SELECT'
    @namor.scrub("Jones, Susan Select Transcriptionist", :suppress => ['select transcriptionist']).should == 'JONES, SUSAN'
    @namor.scrub("Jones, Susan Select Transcriptionist", :suppress => ['transcriptionist', 'select transcriptionist']).should == 'JONES, SUSAN'
  end
end

describe "title suppression" do
  before(:all) do
    @namor = Namor::Namor.new
  end

  it "should only suppress isolated terms" do
    @namor.scrub("Smith, Mary RN", :suppress => ['RN']).should == 'SMITH, MARY'
    @namor.scrub("Smith, Marnie", :suppress => ['RN']).should == 'SMITH, MARNIE'

    @namor.scrub("Gonzalez, Lourdes", :suppress => ['RN', 'RD', 'DO']).should == 'GONZALEZ, LOURDES'
  end

  it "should scrub words with periods" do
    @namor.scrub("Smith, Mary M.D.", :suppress => ['M.D']).should == 'SMITH, MARY'
    @namor.scrub("Smith, Mary M.D.", :suppress => ['RN', 'M.D.', 'DDS']).should == 'SMITH, MARY'
  end

  it "should scrub individual name components of punctuation and titles" do
    @namor.fullscrub('Foxworthy-Smythe, ESQ.', :suppress => ['esq']).should == 'FOXWORTHYSMYTHE'
  end
end
